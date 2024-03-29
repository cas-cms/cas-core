//= require jquery
//= require jquery_ujs
//= require tinymce
//= require cas/vendor/selectize.min
//= require select2
//= require_self

/**
 * Selectize is this lib that overrides <input> and makes them look like a set
 * of tags, so you can add new values with autocompletion, and it's quite
 * snappy.
 */
function initSelectize(element, options) {
  let render = {}
  /**
   * In some cases, we want to allow the user to create new values. For example,
   * when we have a list of tags, we want the user to be able to create new
   * tags.
   *
   * In other cases, such as a list of has-many associations, we don't want the
   * user creating new values.
   */
  if (options.canCreate) {
    render = {
      option_create: function(item, escape) {
        var input = item.input;
        return '<div class="create">' +
          (input ? '<span class="caption">Criar <b>' + escape(input) + '</b></span>' : '') +
          '</div>';
      },
    }
  }

  let items = []
  if (element && element.data('items')) {
    items = element.data('items')
  }

  let params = {
    plugins: ['restore_on_backspace', 'remove_button'],
    delimiter: ',',
    persist: true,
    valueField: 'value',
    labelField: 'text',
    preload: false,
    render: render,
    highlight: true,
    options: element.data('autocomplete'),
    items: items
  }

  if (options.canCreate) {
    params["create"] = function(input) {
      return {
        value: input,
        text: input
      }
    }
  }

  element.selectize(params);
}

$(document).ready(function() {
  $("#select-site").on("change", function(e) {
    var url = $(this).val();
    window.location = url;
  });

  $(".js-select2").select2();

  initSelectize($(".js-tags"), { canCreate: true });
  initSelectize($(".js-has-many-associations"), { canCreate: false });

  tinyMCE.init({
    branding: false,
    promotion: false,
    selector: 'textarea.editor',
    mode : "exact",
    relative_urls : false,
    convert_urls : 0, // default 1
    pagebreak_separator : '<br clear="all" class="pagebreak" />',
    height : '350',
    convert_fonts_to_spans : true,
    font_size_style_values : "8pt,10pt,12pt,14pt,18pt,24pt,36pt",
    inline_styles: false,
    extended_valid_elements: "embed,param,object,iframe[src|title|width|height|allowfullscreen|frameborder]",
    language : "pt_BR",
    plugins : 'image code pagebreak table wordcount link',
    default_link_target: "_blank",
    images_upload_url: paths.fileUpload.path,
    images_upload_credentials: true
  });
});
