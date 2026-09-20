import { describe, it, expect } from 'vitest'
import { loadUploader, upload, imageFile } from './support/load_uploader'

/**
 * Replaces the presign request with one the spec can reject. Returns
 * `rejectAll`, which fires the failure callbacks the manifest attached, with
 * the arguments jQuery would pass.
 */
function stubFailingPresign($) {
  const requests = []

  $.getJSON = function () {
    const request = {
      failCallbacks: [],
      fail(cb) {
        request.failCallbacks.push(cb)
        return request
      }
    }
    requests.push(request)
    return request
  }

  return () =>
    requests.forEach((request) =>
      request.failCallbacks.forEach((cb) =>
        cb({ status: 503 }, 'error', 'Service Unavailable')))
}

function stubSuccessfulPresign($) {
  $.getJSON = function (url, params, callback) {
    callback({
      fields: { key: 'cache/' + params._ },
      url: 'https://s3.example/bucket'
    })
    return { fail() { return this } }
  }
}

const s3Uploads = (urls) => urls.filter((url) => url.indexOf('s3.example') !== -1)

const photos = (count) =>
  Array.from({ length: count }, (_, i) => imageFile('photo-' + (i + 1) + '.jpeg', 500000))

const failureTexts = ($) =>
  $('.upload-failure').map(function () { return $(this).text() }).get()

describe('when a presign request fails', () => {
  it('replaces the stuck progress bar with the reason', async () => {
    const { $ } = await loadUploader()
    const rejectAll = stubFailingPresign($)

    upload($, '.cas-image-gallery [type=file]', photos(1))
    rejectAll()

    expect(failureTexts($)).toEqual(['Falha ao enviar: photo-1.jpeg'])
    expect($('.progress-status')).toHaveLength(0)
  })

  it('names every file in a failed batch', async () => {
    // A presign outage fails the whole selection. Each file says so where its
    // own progress bar was, rather than in one modal per file.
    const { $ } = await loadUploader()
    const rejectAll = stubFailingPresign($)

    upload($, '.cas-image-gallery [type=file]', photos(3))
    rejectAll()

    // Bars are inserted after the input, so the DOM holds them in reverse
    // selection order. Which file failed is what matters, not their order.
    expect(failureTexts($).sort()).toEqual([
      'Falha ao enviar: photo-1.jpeg',
      'Falha ao enviar: photo-2.jpeg',
      'Falha ao enviar: photo-3.jpeg'
    ])
  })

  it('reports attachments too, not just gallery images', async () => {
    const { $ } = await loadUploader()
    const rejectAll = stubFailingPresign($)

    upload($, '.cas-attachments [type=file]', photos(1))
    rejectAll()

    expect(failureTexts($)).toEqual(['Falha ao enviar: photo-1.jpeg'])
  })
})

describe('when an upload to S3 fails', () => {
  const failedUpload = ($, window, attributes) => {
    const progressBar = $('<div class="progress-status"></div>')
    $('.cas-image-gallery .container').append(progressBar)

    window.UploadSharedFunctions.fail(null, Object.assign(
      {files: [{name: 'photo-9.jpeg'}], progressBar: progressBar},
      attributes
    ))
  }

  it('reports it the same way a failed presign is reported', async () => {
    const { $, window } = await loadUploader()

    failedUpload($, window, {})

    expect(failureTexts($)).toEqual(['Falha ao enviar: photo-9.jpeg'])
  })

  it('says nothing when the upload was aborted', async () => {
    // Navigating away aborts everything in flight. Those are not failures to
    // report, and reporting them would also matter the moment a cancel button
    // exists, which a bounded queue makes likely.
    const { $, window } = await loadUploader()

    failedUpload($, window, {errorThrown: 'abort'})

    expect(failureTexts($)).toEqual([])
  })
})

describe('upload concurrency', () => {
  // A whole camera roll otherwise starts one upload per file at once, which
  // saturates a phone's connection and is what makes the uploads fail.
  it('uploads only a few files at a time', async () => {
    const { $, requestedUrls } = await loadUploader()
    stubSuccessfulPresign($)

    upload($, '.cas-attachments [type=file]', photos(10))
    await new Promise((resolve) => setTimeout(resolve, 100))

    expect(s3Uploads(requestedUrls)).toHaveLength(5)
  })

  it('queues the gallery uploader too', async () => {
    // The gallery's image processing needs canvas, which JSDOM lacks, so the
    // resize step is dropped here. The queueing under test is unaffected.
    const { $, requestedUrls } = await loadUploader()
    stubSuccessfulPresign($)
    $('.cas-image-gallery [type=file]').fileupload('option', 'processQueue', [])

    upload($, '.cas-image-gallery [type=file]', photos(10))
    await new Promise((resolve) => setTimeout(resolve, 100))

    expect(s3Uploads(requestedUrls)).toHaveLength(5)
  })
})
