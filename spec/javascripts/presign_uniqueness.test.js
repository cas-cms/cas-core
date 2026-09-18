import { describe, it, expect } from 'vitest'
import { loadUploader, upload, imageFile } from './support/load_uploader'

const SAME_MILLISECOND = 1789752301282

function presignUrls(requestedUrls) {
  return requestedUrls.filter((url) => url.indexOf('/admin/files/cache/presign') === 0)
}

describe('presign requests', () => {
  it('asks for a presign once per file', async () => {
    const { $, requestedUrls } = await loadUploader()

    upload($, '.cas-image-gallery [type=file]', [
      imageFile('IMG_8960.jpeg', 963331),
      imageFile('IMG_8961.jpeg', 717305),
      imageFile('IMG_8962.jpeg', 916134)
    ])

    expect(presignUrls(requestedUrls)).toHaveLength(3)
  })

  it('uses a distinct URL per file when several are added in the same millisecond', async () => {
    // HUM-199. `_onAdd` fires the add callback once per file synchronously, so
    // every file selected in the same millisecond builds the same presign URL
    // and all of those requests are in flight at once. The browser coalesces
    // concurrent identical GETs and delivers one response to all of them, so
    // every such file receives the SAME presigned S3 key and they silently
    // overwrite each other on upload. In production 39 files shared 8 keys.
    const { $, requestedUrls } = await loadUploader({ now: SAME_MILLISECOND })

    upload($, '.cas-image-gallery [type=file]', [
      imageFile('IMG_8960.jpeg', 963331),
      imageFile('IMG_8961.jpeg', 717305),
      imageFile('IMG_8962.jpeg', 916134),
      imageFile('IMG_8964.jpeg', 1030821),
      imageFile('IMG_8966.jpeg', 775132)
    ])

    const urls = presignUrls(requestedUrls)
    expect(new Set(urls).size).toBe(urls.length)
  })

  it('does not repeat a URL across the image and attachment uploaders', async () => {
    // Both uploaders presign against the same endpoint, so they have to draw
    // from one sequence. A per-uploader counter would let the first file of
    // each collide.
    const { $, requestedUrls } = await loadUploader({ now: SAME_MILLISECOND })

    upload($, '.cas-image-gallery [type=file]', [imageFile('IMG_8960.jpeg', 963331)])
    upload($, '.cas-attachments [type=file]', [imageFile('IMG_8961.jpeg', 717305)])

    const urls = presignUrls(requestedUrls)
    expect(urls).toHaveLength(2)
    expect(new Set(urls).size).toBe(2)
  })
})
