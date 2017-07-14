// jquery already loaded
//= require jquery-ui/widgets/sortable
//= require cas/vendor/jquery.ui.touch-punch.min.js
//
// widget needs only when jquery ui is not included
// require cas/vendor/file_upload/jquery.ui.widget
//= require cas/vendor/file_upload/load-image.all.min
//= require cas/vendor/file_upload/canvas-to-blob.min
//= require cas/vendor/file_upload/jquery.iframe-transport
//= require cas/vendor/file_upload/jquery.fileupload
//= require cas/vendor/file_upload/jquery.fileupload-process
//= require cas/vendor/file_upload/jquery.fileupload-image
//= require cas/plugins/cas_image_gallery
//= require_self

$(function() {
  var gallery = new CasImageGallery({
    element: $(".cas-image-gallery"),
    selectionEnabled: false,
    preloadedImagesElements: $(".cas-image-gallery .cas-gallery-preloaded"),
    onDelete: function(ids) {
      if (confirm("Tem certeza disso?")) {
        return $.ajax("" + paths.deleteImages.path + "/" + ids.join(), {
          method: paths.deleteImages.method
        });
      } else {
        return false;
      }
    }
  });
  gallery.init();

  $(".cas-image-gallery .images").sortable({
    stop: function() {
      gallery.resetImagesOrder();
    }
  });

  $('[type=file]').fileupload({
    maxChunkSize: 10000000, // 10000000 = 10mb
    dropZone: $('.dropzone'),
    dataType: 'json',
    disableImageResize: /Android(?!.*Chrome)|Opera/.test(window.navigator && navigator.userAgent),
    imageMaxWidth:  1920,
    imageMaxHeight: 1920,
    add: function(e, data) {
      $.blueimp.fileupload.prototype.options.add.call(this, e, data);

      data.progressBar = $('<div class="progress-status"><span class="name">&nbsp;</span><div class="progress-bar"></div></div>');
      $(this).after(data.progressBar);

      var options = {
        extension: data.files[0].name.match(/(\.\w+)?$/)[0], // set extension
        _: Date.now(),                                       // prevent caching
      }
      $.getJSON('/admin/files/cache/presign', options, function(result) {
        data.formData = result['fields'];
        data.url = result['url'];
        data.paramName = 'file';
        data.submit();
      });
    },
    progress: function(e, data) {
      var progress = parseInt(data.loaded / data.total * 100, 10);
      var percentage = progress.toString() + '%'
      data.progressBar.find(".progress-bar").css("width", percentage);
      data.progressBar.find(".name").html(percentage);
    },
    fail: function(e, data) {
      console.log("error", e);
      console.log("data", data);
      data.progressBar.remove();
      alert('Falha ao enviar arquivo: '+data.files[0].name);
    },
    done: function(e, data) {
      data.progressBar.remove();

      var file = {
        id: data.formData.key.match(/cache\/(.+)/)[1], // we have to remove the prefix part
        storage: 'cache',
        metadata: {
          size:      data.files[0].size,
          filename:  data.files[0].name.match(/[^\/\\]*$/)[0], // IE returns full path
          mime_type: data.files[0].type
        }
      }

      var fileInput = $(this);
      var fileInputName = $(this).attr("name");
      var fileImagesGallery = $(fileInput.data("images"));

      $.ajax("/admin/api/files", {
        method: 'POST',
        data: {
          data: {
            attributes: {
              metadata: file
            },
            relationships: {
              data: {
                type: gallery.attachable().type,
                id:   gallery.attachable().id
              }
            }
          }
        }
      }).done(function(response) {
        var id = response.data.id;
        var url = response.data.attributes.url;
        gallery.addImage(url, id);
      });
    }
  });
});
