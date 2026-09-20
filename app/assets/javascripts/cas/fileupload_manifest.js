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
var gallery;

/**
 * Builds a value that makes each presign request URL unique.
 *
 * Date.now() alone is not enough. `_onAdd` fires the `add` callback once per
 * file synchronously, many files per millisecond, so every file selected within
 * the same millisecond builds a byte-identical presign URL and all of those
 * requests go out at once. Some clients answer those duplicates from a single
 * load: in one reported batch only a handful of requests reached the server,
 * and the files sharing a URL also shared one presigned S3 key, overwriting
 * each other on upload until most of the batch was gone.
 *
 * Which clients do this is not settled. Desktop Chrome and desktop Safari both
 * issue every request and so never collide; the batch that lost files came from
 * mobile Safari. Making the URLs differ removes the precondition entirely, so
 * it stops mattering. The server cannot help here: Shrine's presign endpoint
 * already sends `Cache-Control: no-store`. This is the same scheme as jQuery's
 * own `cache: false` nonce, a counter seeded from the clock. See
 * spec/javascripts/presign_uniqueness.test.js.
 */
var presignRequestCount = 0;
function presignCacheBuster() {
  presignRequestCount += 1;
  return Date.now() + '-' + presignRequestCount;
}

/**
 * Turns a file's progress bar into its error message, in place.
 *
 * A selection is one action by the user and an outage fails every file in it,
 * so one modal per file is unusable on a phone. Reporting where the bar was
 * says which files failed, next to where the user was already looking, and
 * leaves the successful ones alone.
 */
function reportFailedUpload(data) {
  data.progressBar
    .removeClass('progress-status')
    .addClass('upload-failure')
    .text('Falha ao enviar: '+data.files[0].name);
}

/**
 * Shared functions
 *
 * These are functions that are used for both images and generic attachments.
 */
var UploadSharedFunctions = {
  progress: function(e, data) {
    var progress = parseInt(data.loaded / data.total * 100, 10);
    var percentage = progress.toString() + '%'
    data.progressBar.find(".progress-bar").css("width", percentage);
    data.progressBar.find(".name").html(percentage);
  },
  fail: function(e, data) {
    console.log("error", e);
    console.log("data", data);
    if (data.errorThrown === 'abort') { return; }

    reportFailedUpload(data);
  },

  /**
   * Without this a file whose presign request failed keeps a progress bar at
   * 0% for ever and is silently never uploaded.
   */
  presignFailed: function(data, jqXHR, textStatus) {
    console.log("presign failed", textStatus, jqXHR && jqXHR.status);
    reportFailedUpload(data);
  }
};

/**
 * Image gallery upload functions
 *
 * These functions are only used by the upload mechanism intented for the upload
 * of images for the gallery, not general attachments.
 */
var ImageGalleryUploadFunctions = {
  add: function(e, data) {
    var acceptFileTypes = /^image\/(gif|jpe?g|png|tiff)$/i;

    for (var index in data.originalFiles) {
      var file = data.originalFiles[index];
      if(file['type'].length && !acceptFileTypes.test(file['type'])) {
        alert('O arquivo enviado não é uma imagem.');
        return false;
      }
    }

    var that = this;

    data.progressBar = $('<div class="progress-status"><span class="name">&nbsp;</span><div class="progress-bar"></div></div>');
    $(this).after(data.progressBar);

    var options = {
      extension: data.files[0].name.match(/(\.\w+)?$/)[0], // set extension
      _: presignCacheBuster(),                             // must be unique per file
    }

    $.getJSON('/admin/files/cache/presign', options, function(result) {
      console.log("image: presign result", result);
      console.log("image: now will submit file to S3 URL: ", result["url"]);
      data.formData = result['fields'];
      data.url = result['url'];
      data.paramName = 'file';
      $.blueimp.fileupload.prototype.options.add.call(that, e, data);
      data.submit();
    }).fail(function(jqXHR, textStatus) {
      UploadSharedFunctions.presignFailed(data, jqXHR, textStatus);
    });
  },
  done: function(e, data) {
    console.log("Image: upload done! Now posting to /admin/api/files", data.formData);
    data.progressBar.remove();

    var file = {
      original: {
        id: data.formData.key.match(/cache\/(.+)/)[1], // we have to remove the prefix part
        storage: 'cache',
        metadata: {
          size:      data.files[0].size,
          filename:  data.files[0].name.match(/[^\/\\]*$/)[0], // IE returns full path
          mime_type: data.files[0].type
        }
      }
    }

    var fileInput = $(this);
    var fileInputName = $(this).attr("name");
    var fileImagesGallery = $(fileInput.data("images"));

    console.log("image: posting to /admin/api/files");
    $.ajax("/admin/api/files", {
      method: 'POST',
      data: {
        data: {
          attributes: {
            metadata: file,
            media_type: 'image'
          },
          relationships: {
            attachable: {
              data: {
                type: gallery.attachable().type,
                id:   gallery.attachable().id
              }
            }
          }
        }
      }
    }).done(function(response) {
      var id = response.data.id;
      var url = response.data.attributes.url;
      var filename = response.data.attributes["original-name"];
      gallery.addImage({
        url: url,
        id: id,
        filename: filename,
        orderBy: "filename"
      });
    });
  }
};

var AttachmentUploadFunctions = {
  add: function(e, data) {
    data.progressBar = $('<div class="progress-status"><span class="name">&nbsp;</span><div class="progress-bar"></div></div>');
    $(this).after(data.progressBar);

    var options = {
      extension: data.files[0].name.match(/(\.\w+)?$/)[0], // set extension
      _: presignCacheBuster(),                             // must be unique per file
    }

    $.getJSON('/admin/files/cache/presign', options, function(result) {
      console.log("Attachment presign result", result);
      data.formData = result['fields'];
      data.url = result['url'];
      data.paramName = 'file';
      data.submit();
    }).fail(function(jqXHR, textStatus) {
      UploadSharedFunctions.presignFailed(data, jqXHR, textStatus);
    });
  },
  done: function(e, data) {
    console.log("Attachment upload done! Now posting to /admin/api/files");
    data.progressBar.remove();

    var file = {
      original: {
        id: data.formData.key.match(/cache\/(.+)/)[1], // we have to remove the prefix part
        storage: 'cache',
        metadata: {
          size:      data.files[0].size,
          filename:  data.files[0].name.match(/[^\/\\]*$/)[0], // IE returns full path
          mime_type: data.files[0].type
        }
      }
    }

    var fileInput = $(this);
    var fileInputName = $(this).attr("name");
    var fileImagesGallery = $(fileInput.data("images"));

    console.log("Attachment: posting to /admin/api/files");
    $.ajax("/admin/api/files", {
      method: 'POST',
      data: {
        data: {
          attributes: {
            metadata: file,
            media_type: 'attachment'
          },
          relationships: {
            attachable: {
              data: {
                type: gallery.attachable().type,
                id:   gallery.attachable().id
              }
            }
          }
        }
      }
    }).done(function(response) {
      var id = response.data.id;
      var url = response.data.attributes.url;
      var filename = response.data.attributes["original-name"];
      var itemTemplate = $("#cas-attachments-template").html();
      var finalHtml = $(itemTemplate);

      finalHtml.attr("data-id", id);
      finalHtml.find(".filename").html(filename);

      $("#attachments-list").append(finalHtml);
      /**
       * order is set to 0 all for now
       */
      $("#attachments-list").append("<input type='hidden' name='attachments[files][0][id]' class='js-attachment-input' value='"+id+"' />");
    });
  }
};

function deleteFiles(ids) {
  if (confirm("Tem certeza disso?")) {
    return $.ajax("" + paths.deleteFile.path + "/" + ids.join(), {
      method: paths.deleteFile.method
    });
  } else {
    return false;
  }
}

$(function() {
  gallery = new CasImageGallery({
    element: $(".cas-image-gallery"),
    selectionEnabled: false,
    preloadedImagesElements: $(".cas-image-gallery .cas-gallery-preloaded"),
    onDelete: deleteFiles
  });
  gallery.init();

  $(".cas-image-gallery .images").sortable({
    stop: function() {
      gallery.resetImagesOrder();
    }
  });

  $('.cas-image-gallery [type=file]').fileupload({
    maxChunkSize: 10000000, // 10000000 = 10mb
    /**
     * How many uploads run at once, NOT how many files can be selected. The
     * whole selection is still uploaded: the rest wait in the widget's queue
     * and the next one starts each time an upload finishes. Without this,
     * picking a camera roll starts every upload simultaneously and saturates
     * the connection they all need, which is what makes them fail.
     *
     * Presign requests are not bounded by this. They are issued from the add
     * callback, which runs once per file when the files are picked, before
     * anything reaches the upload queue.
     */
    limitConcurrentUploads: 3,
    dropZone: $('.cas-image-gallery.dropzone'),
    dataType: 'json',
    disableImageResize: /Android(?!.*Chrome)|Opera/.test(window.navigator && navigator.userAgent),
    imageMaxWidth:  1920,
    imageMaxHeight: 1920,
    imageOrientation: true,
    prependFiles: true,

    // callbacks
    add: ImageGalleryUploadFunctions.add,
    progress: UploadSharedFunctions.progress,
    fail: UploadSharedFunctions.fail,
    done: ImageGalleryUploadFunctions.done
  });

  $('.cas-attachments [type=file]').fileupload({
    maxChunkSize: 10000000, // 10000000 = 10mb
    limitConcurrentUploads: 3, // see the gallery uploader above
    dropZone: $('.cas-attachments.dropzone'),
    dataType: 'json',

    // callbacks
    add: AttachmentUploadFunctions.add,
    progress: UploadSharedFunctions.progress,
    fail: UploadSharedFunctions.fail,
    done: AttachmentUploadFunctions.done
  });

  // DELETING ATTACHMENTS
  $('.cas-attachments').on('click', '.js-delete-file', function(el) {
    var fileEl = $(this).parents("[data-id]");
    var id = [fileEl.attr('data-id')];
    var response = deleteFiles(id);
    if (response) {
      response.done(function() {
        fileEl.remove();
      });
    }
  });
});
