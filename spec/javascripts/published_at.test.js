import { describe, it, expect } from 'vitest'
import { loadPublishedAt, hidden } from './support/load_published_at'

describe('publication date behind a link', () => {
  it('hides the selects until the editor asks for another date', async () => {
    const { $ } = await loadPublishedAt()

    expect(hidden($('.published-at-selects'))).toBe(true)
    expect(hidden($('.published-at-summary'))).toBe(false)
    // The select is inside the hidden wrapper, not beside it.
    expect($('.published-at-selects #content_published_at_1i')).toHaveLength(1)

    $('.js-choose-published-at').trigger('click')

    expect(hidden($('.published-at-selects'))).toBe(false)
    expect(hidden($('.published-at-summary'))).toBe(true)
  })

  it('shows the stored date as text and reveals the selects on "alterar"', async () => {
    const { $ } = await loadPublishedAt({ chosen: true })

    expect($('.published-at-summary').text()).toContain('20/05/2012')
    expect(hidden($('.published-at-selects'))).toBe(true)

    $('.js-choose-published-at').trigger('click')

    expect(hidden($('.published-at-selects'))).toBe(false)
  })

  it('does not navigate when the link is clicked', async () => {
    const { $, window } = await loadPublishedAt()
    const before = window.location.href

    $('.js-choose-published-at').trigger('click')

    expect(window.location.href).toBe(before)
  })

  it('follows the Publicado? checkbox', async () => {
    const { $ } = await loadPublishedAt()

    expect(hidden($('.js-published-at'))).toBe(false)

    $('#content_published').prop('checked', false).trigger('change')
    expect(hidden($('.js-published-at'))).toBe(true)

    $('#content_published').prop('checked', true).trigger('change')
    expect(hidden($('.js-published-at'))).toBe(false)
  })

  it('keeps a date chosen before the box was unticked', async () => {
    // Hidden, not disabled: the selects still submit, so a date picked and
    // then parked as a draft is there when the content is published later.
    const { $ } = await loadPublishedAt()

    $('.js-choose-published-at').trigger('click')
    $('#content_published_at_1i').val('2012')
    $('#content_published').prop('checked', false).trigger('change')

    expect($('#content_published_at_1i').prop('disabled')).toBe(false)
    expect($('#content_published_at_1i').val()).toBe('2012')
  })

  it('keeps a dated draft\'s date readable when the box is unticked', async () => {
    const { $ } = await loadPublishedAt({ chosen: true })

    $('#content_published').prop('checked', false).trigger('change')

    expect(hidden($('.js-published-at'))).toBe(false)
    expect(hidden($('.published-at-summary'))).toBe(false)
  })

  it('opens the selects when the server flags a date error', async () => {
    const { $ } = await loadPublishedAt({ chosen: true, open: true })

    expect(hidden($('.published-at-selects'))).toBe(false)
  })

  it('stays visible for a section without the checkbox', async () => {
    const { $ } = await loadPublishedAt({ withCheckbox: false })

    expect(hidden($('.js-published-at'))).toBe(false)
  })
})
