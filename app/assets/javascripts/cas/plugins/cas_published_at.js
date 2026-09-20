// Publication date behind a link.
//
// The date selects are rendered on every content form but hidden until the
// editor clicks "Publicar noutra data" (or "alterar" on a content that has a
// date). Left alone, they submit blank and the model stamps the publication
// moment when the content is first published.
//
// The block follows the "Publicado?" checkbox named by data-follows: an
// undated draft has nothing to show, so it hides; a dated one keeps its date
// readable (data-chosen). A re-render carrying a date error opens the selects
// so the message next to them is visible (data-open).
(function ($) {
  'use strict';

  function PublishedAtField(root) {
    this.$root = root;
    this.$summary = root.find('.published-at-summary');
    this.$selects = root.find('.published-at-selects');
    this.$published = $(root.data('follows'));
    this.chosen = root.data('chosen') === true;
    this.open = root.data('open') === true;
  }

  PublishedAtField.prototype.attach = function () {
    var field = this;

    if (this.open) {
      this.reveal();
    } else {
      this.$selects.hide();
    }

    this.$summary.on('click', '.js-choose-published-at', function (event) {
      event.preventDefault();
      field.reveal();
    });

    if (this.$published.length) {
      this.$published.on('change', function () { field.follow(); });
      this.follow();
    }
  };

  PublishedAtField.prototype.reveal = function () {
    this.$summary.hide();
    this.$selects.show();
  };

  PublishedAtField.prototype.follow = function () {
    this.$root.toggle(this.$published.is(':checked') || this.chosen);
  };

  $(function () {
    $('.js-published-at').each(function () {
      new PublishedAtField($(this)).attach();
    });
  });
})(jQuery);
