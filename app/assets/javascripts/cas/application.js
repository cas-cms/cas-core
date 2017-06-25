//= require jquery
//= require jquery_ujs
//= require cas/vendor/selectize.min
//= require_tree .

$(document).ready(function() {
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
});
