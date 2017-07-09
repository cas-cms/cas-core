// jquery already loaded
//
//= require cas/vendor/file_upload/jquery.ui.widget
//= require cas/vendor/file_upload/jquery.iframe-transport
//= require cas/vendor/file_upload/jquery.fileupload
//= require cas/plugins/cas_image_gallery
//= require_self

$(function() {
  $('[type=file]').fileupload({
    maxChunkSize: 10000000, // 10000000 = 10mb
    add: function(e, data) {
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
      alert('Falha ao enviar arquivo.');
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
            }
          }
        }
      }).done(function(response) {
        var id = response.data.id;
        var imageUrl = response.data.attributes.url;
        console.log("response", response);
        fileInput.after("<input type='hidden' name='files[][id]' value='"+id+"' />");

        var image = $('<div class="image js-image" data-id="'+id+'" style="background-image: url(\''+imageUrl+'\');"></div>');
        $(".images").append(image);
        console.log("upload done");
      });
    }
  });

  var gallery = new CasImageGallery({
    element: $(".cas-image-gallery"),
    selectionEnabled: true,
    onDelete: function(ids) {
      console.log("onDelete", ids);
    }
  });
  gallery.init();
  $(".image-container:nth(2)").click();
  $(".image-container:nth(3)").click();
});
