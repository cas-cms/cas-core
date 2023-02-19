//= require jquery
//= require jquery_ujs
// require tinymce-jquery
//= require cas/vendor/selectize.min
//= require_self

$(document).ready(function() {
  $("#select-site").on("change", function(e) {
    var url = $(this).val();
    window.location = url;
  });

  $(".js-tags").selectize({
    plugins: ['restore_on_backspace', 'remove_button'],
    delimiter: ',',
    persist: true,
    preload: false,
    render: {
      option_create: function(item, escape) {
        var input = item.input;
        return '<div class="create">' +
          (input ? '<span class="caption">Criar <b>' + escape(input) + '</b></span>' : '') +
          '</div>';
      },
    },
    create: function(input) {
      return {
        value: input,
        text: input
      }
    },
    onInitialize: function(){
      var selectize = this;
      var data = this.$input.data('autocomplete');
      selectize.addOption(data);
    }
  });

  tinyMCE.init({
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
    plugins : 'image,imagetools,code,paste,pagebreak,table,wordcount,link',
    default_link_target: "_blank",
    images_upload_url: paths.fileUpload.path,
    images_upload_credentials: true
  });
});
