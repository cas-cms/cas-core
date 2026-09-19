import { describe, it, expect } from 'vitest'
import { loadUploader, upload, imageFile } from './support/load_uploader'

const SAME_MILLISECOND = 1700000000000

function presignUrls(requestedUrls) {
  return requestedUrls.filter((url) => url.indexOf('/admin/files/cache/presign') === 0)
}

describe('presign requests', () => {
  it('asks for a presign once per file', async () => {
    const { $, requestedUrls } = await loadUploader()

    upload($, '.cas-image-gallery [type=file]', [
      imageFile('photo-1.jpeg', 501000),
      imageFile('photo-2.jpeg', 502000),
      imageFile('photo-3.jpeg', 503000)
    ])

    expect(presignUrls(requestedUrls)).toHaveLength(3)
  })

  it('uses a distinct URL per file when several are added in the same millisecond', async () => {
    // `_onAdd` fires the add callback once per file synchronously, so every
    // file selected in the same millisecond builds the same presign URL and
    // all of those requests are in flight at once. The browser coalesces
    // concurrent identical GETs and delivers one response to all of them, so
    // every such file receives the SAME presigned S3 key and they silently
    // overwrite each other on upload.
    const { $, requestedUrls } = await loadUploader({ now: SAME_MILLISECOND })

    upload($, '.cas-image-gallery [type=file]', [
      imageFile('photo-1.jpeg', 501000),
      imageFile('photo-2.jpeg', 502000),
      imageFile('photo-3.jpeg', 503000),
      imageFile('photo-4.jpeg', 504000),
      imageFile('photo-5.jpeg', 505000)
    ])

    const urls = presignUrls(requestedUrls)
    expect(new Set(urls).size).toBe(urls.length)
  })

  it('does not repeat a URL across the image and attachment uploaders', async () => {
    // Both uploaders presign against the same endpoint, so they have to draw
    // from one sequence. A per-uploader counter would let the first file of
    // each collide.
    const { $, requestedUrls } = await loadUploader({ now: SAME_MILLISECOND })

    upload($, '.cas-image-gallery [type=file]', [imageFile('photo-1.jpeg', 501000)])
    upload($, '.cas-attachments [type=file]', [imageFile('photo-2.jpeg', 502000)])

    const urls = presignUrls(requestedUrls)
    expect(urls).toHaveLength(2)
    expect(new Set(urls).size).toBe(2)
  })
})
