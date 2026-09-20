import fs from 'fs'
import path from 'path'
import { JSDOM } from 'jsdom'

// Pinned in package.json to the version jquery-rails 4.3.1 vendors, which is
// what the engine actually serves. Keep the two in step.
const JQUERY = path.resolve(process.cwd(), 'node_modules/jquery/dist/jquery.js')
const PLUGIN = path.resolve(process.cwd(), 'app/assets/javascripts/cas/plugins/cas_published_at.js')

/**
 * Markup shaped like _published_field.html.erb followed by
 * _published_at_field.html.erb. The acceptance spec pins the real partial to
 * these class and data hooks. `chosen` is a content that already has a date;
 * `open` is a re-render carrying a published_at error; `withCheckbox: false`
 * is a section whose cas.yml lists published_at but not published.
 */
function markup({ chosen, open, withCheckbox }) {
  const checkbox = withCheckbox
    ? '<input type="checkbox" id="content_published" checked>'
    : ''
  const summary = chosen
    ? 'Data de publicação: 20/05/2012 <a href="#" class="js-choose-published-at">alterar</a>'
    : '<a href="#" class="js-choose-published-at">Publicar noutra data</a>'
  // simple_form emits a <div class="input"> around the selects; the wrappers
  // must be divs too, since a <p> would be closed by it and hide nothing.
  return `
    <form>
      ${checkbox}
      <div class="js-published-at" data-follows="#content_published" data-chosen="${chosen}" data-open="${open}">
        <div class="published-at-summary">${summary}</div>
        <div class="published-at-selects">
          <div class="input date optional content_published_at">
            <label>Data de publicação:</label>
            <select id="content_published_at_1i"><option value=""></option><option>2012</option></select>
          </div>
        </div>
      </div>
    </form>
  `
}

/**
 * Boots the real plugin inside JSDOM with real jQuery. JSDOM does no layout,
 * so visibility is read from the inline style jQuery's show/hide sets rather
 * than from `:visible`.
 */
export async function loadPublishedAt({ chosen = false, open = false, withCheckbox = true } = {}) {
  const dom = new JSDOM(markup({ chosen, open, withCheckbox }), { runScripts: 'outside-only' })
  const window = dom.window

  window.eval(fs.readFileSync(JQUERY, 'utf8'))
  window.eval(fs.readFileSync(PLUGIN, 'utf8'))
  const $ = window.jQuery

  await new Promise((resolve) => setTimeout(resolve, 0))

  return { $, window }
}

export const hidden = ($el) => $el[0].style.display === 'none'
