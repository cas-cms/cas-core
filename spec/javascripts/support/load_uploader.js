import fs from 'fs'
import path from 'path'
import { JSDOM } from 'jsdom'

// Pinned in package.json to the version jquery-rails 4.3.1 vendors, which is
// what the engine actually serves. Keep the two in step.
const JQUERY = path.resolve(process.cwd(), 'node_modules/jquery/dist/jquery.js')
const ASSETS = path.resolve(process.cwd(), 'app/assets/javascripts/cas')

/**
 * The files fileupload_manifest.js requires, in its order, with one
 * substitution: production takes the jQuery UI widget factory from
 * jquery-ui-rails (`//= require jquery-ui/widgets/sortable`) and therefore
 * leaves the vendored copy commented out. That gem is not available here, so we
 * load the vendored widget factory instead. It is the same factory.
 */
const SCRIPTS = [
  'vendor/file_upload/jquery.ui.widget.js',
  'vendor/file_upload/load-image.all.min.js',
  'vendor/file_upload/canvas-to-blob.min.js',
  'vendor/file_upload/jquery.iframe-transport.js',
  'vendor/file_upload/jquery.fileupload.js',
  'vendor/file_upload/jquery.fileupload-process.js',
  'vendor/file_upload/jquery.fileupload-image.js',
  'plugins/cas_image_gallery.js',
  'fileupload_manifest.js'
]

const MARKUP = `
  <div class="cas-image-gallery dropzone" data-attachable-type="contents" data-attachable-id="055a4b3b">
    <div class="container">
      <div class="upload-input"><input type="file" multiple></div>
      <script id="cas-gallery-image-template" type="text/x-custom-template">
        <div class="image-container"><div class="image"></div></div>
      </script>
      <div class="images"></div>
    </div>
  </div>
  <div class="cas-attachments dropzone"><input type="file"></div>
  <div id="attachments-list"></div>
`

/**
 * Boots the real admin uploader inside JSDOM: real jQuery, the real vendored
 * jQuery-File-Upload stack, the real gallery plugin and the real manifest,
 * against markup shaped like _form_images.html.erb.
 *
 * Returns `requestedUrls`, the URLs jQuery actually handed to XMLHttpRequest.
 * Capturing at the transport rather than stubbing $.getJSON means the specs do
 * not have to restate how jQuery serialises parameters into a URL.
 */
export async function loadUploader({ now } = {}) {
  const dom = new JSDOM(MARKUP, { runScripts: 'outside-only' })
  const window = dom.window
  const requestedUrls = []

  window.XMLHttpRequest.prototype.open = function (method, url) { requestedUrls.push(url) }
  window.XMLHttpRequest.prototype.send = function () {}
  window.XMLHttpRequest.prototype.setRequestHeader = function () {}

  window.eval(fs.readFileSync(JQUERY, 'utf8'))
  const $ = window.jQuery

  if (now !== undefined) window.Date.now = () => now

  // From jquery-ui-rails, irrelevant to uploading.
  $.fn.sortable = function () { return this }

  for (const script of SCRIPTS) {
    window.eval(fs.readFileSync(path.join(ASSETS, script), 'utf8'))
  }

  // Let jQuery's ready queue drain so the manifest's bootstrap runs.
  await new Promise((resolve) => setTimeout(resolve, 0))

  return { window, $, dom, requestedUrls }
}

export function upload($, selector, files) {
  $(selector).fileupload('add', { files })
}

export function imageFile(name, size) {
  return { name, size, type: 'image/jpeg' }
}
