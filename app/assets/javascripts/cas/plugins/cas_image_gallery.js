function CasImage(element, gallery) {
  var image = this;
  image.element = element;
  image.gallery = gallery;

  image.id = image.element.attr("data-id");

  image.isSelected = function() {
    return image.element.attr("data-selected") == "true";
  };

  image.markAsSelected = function() {
    image.element.attr("data-selected", "true");
  };

  image.unselect = function() {
    image.element.find(".selection").hide();
    image.element.attr("data-selected", "false");
    image.element.find(".unselected-but-selectable").show();
  };

  image.toggleSelection = function() {
    if (image.isSelected()) {
      image.unselect();
    } else {
      image.markAsSelected();
      image.element.find(".unselected-but-selectable").hide();
      image.element.find(".selection").show();
    }
  };

  image.showEditOptions = function() {
    gallery.element.find(".image .image-options").hide();
    image.element.find(".image .image-options").show();
    image.markAsSelected();
  };

  return {
    click: function() {
      if (image.gallery.isSelectionEnabled) {
        image.toggleSelection();
      } else {
        image.showEditOptions();
      }
    },
    unselect: function() {
      if (image.isSelected()) {
        image.unselect();
      }
    },
    recordId: function() {
      return image.element.data("id");
    },
    addOrderedInput: function(order) {
      if (!image.element.find("input.js-image-input").length) {
        image.element.append("<input type='hidden' name='images[files]["+order+"][id]' class='js-image-input' value='"+image.id+"' />");
      }
    }
  }
}

function CasImageGallery(options) {
  var gallery = this;
  gallery.element = options.element;

  gallery.isSelectionEnabled = options.selectionEnabled || false;
  gallery.preloadedImagesSelector = options.preloadedImagesElements || gallery.element.find(".cas-gallery-preloaded");

  gallery.allItems = function() {
    return gallery.element.find(".image-container");
  };

  gallery.unselectAll = function() {
    gallery.allItems().each(function(index) {
      var image = new CasImage($(this), gallery);
      image.unselect();
    });
  };

  gallery.getSelectedItems = function() {
    var result = [];
    return gallery.element.find(".image-container[data-selected=true]").map(function(index, value) {
      return $(value)
    });
  };

  gallery.toggleSelection = function() {
    gallery.isSelectionEnabled = !gallery.isSelectionEnabled;

    if (!gallery.isSelectionEnabled) {
      gallery.unselectAll();
    } else {
      gallery.unselectAll();
      gallery.element.find(".unselected-but-selectable").show();
    }

    gallery.updateUi();
  };

  gallery.markAsCover = function(id) {
    gallery.element.find(".image-container").attr("data-is-cover", "false");
    gallery.element.find(".image-container[data-id="+id+"]").attr("data-is-cover", "true");
    gallery.element.find("input.js-image-cover-input").remove();
    gallery.element.append("<input type='hidden' name='images[cover_id]' class='js-image-cover-input' value='"+id+"' />");
  };

  gallery.deleteImages = function() {
    var ids = [];
    gallery.getSelectedItems().each(function(index, imageElement) {
      var image = new CasImage(imageElement, gallery);
      ids.push( String(image.recordId()) );
    });
    var response = options.onDelete(ids);

    if (response) {
      response.done(function() {
        var imageSelectors = [];
        $.each(ids, function(index, value) {
          imageSelectors.push(".image-container[data-id="+value+"]");
        });
        gallery.element.find(imageSelectors.join(", ")).remove();
        gallery.unselectAll();
        if (gallery.isSelectionEnabled) {
          gallery.toggleSelection();
        }
      }).fail(function() {
        alert("Error!");
      });
    }
  };

  gallery.imageClicked = function(element) {
    if (!gallery.isSelectionEnabled) {
      gallery.unselectAll();
    }

    var image = new CasImage($(element), gallery);
    image.click();
    gallery.updateUi();
  };

  gallery.setupEvents = function() {
    options.element.on("click", ".image-container", function() {
      gallery.imageClicked($(this));
    });

    options.element.on("click", ".js-toggle-selection", function() {
      gallery.toggleSelection();
    });

    options.element.on("click", ".js-delete-image", function() {
      gallery.deleteImages();
    });

    options.element.on("click", ".js-mark-as-cover", function() {
      var id = $(this).parents(".image-container").data("id");
      gallery.markAsCover(id);
    });

    /*
     * There's a bug with dragleave when over child elements, flickering. This
     * fixes it.
     */
    var dropzoneLastEnter;
    $(document)
      .on('dragover dragenter', ".dropzone", function(e) {
        dropzoneLastEnter = event.target;
        e.preventDefault();

        var dataTransfer = e.originalEvent.dataTransfer;
        if (dataTransfer.types && (dataTransfer.types.indexOf ? dataTransfer.types.indexOf('Files') != -1 : dataTransfer.types.contains('Files'))) {
          $(this).addClass('in');
        }
      })
      .on('dragleave drop', ".dropzone", function(e) {
        if (dropzoneLastEnter === event.target) {
          $(this).removeClass('in');
        }
      });
  };

  gallery.preloadImages = function() {
    var images = gallery.preloadedImagesSelector;

    $.each(images, function(index, value) {
      var image = $(value);
      var url = image.data("src");
      var id = image.data("id");
      var isCover = image.data("is-cover");
      gallery.addImage(url, id, isCover);
    });
  };

  gallery.imageTemplate = $("#cas-gallery-image-template").html();
  gallery.addImage = function(url, id, isCover) {
    var finalHtml = $(gallery.imageTemplate);

    finalHtml.attr("data-id", id);
    finalHtml.find(".image").css("backgroundImage", "url('"+url+"')");

    var orderCount = String(gallery.element.find("input.js-image").length);

    gallery.element.find(".images").append(finalHtml);
    gallery.refreshImagesFormInputs();
    gallery.unselectAll();

    if (isCover) {
      gallery.markAsCover(id);
    }

    gallery.updateUi();
  };

  gallery.refreshImagesFormInputs = function() {
    gallery.allItems().each(function(index) {
      var image = new CasImage($(this), gallery);
      image.addOrderedInput(index);
    });
  };

  gallery.updateUi = function() {
    if (gallery.isSelectionEnabled) {
      gallery.element.find(".when-selection-enabled").show();
      gallery.element.find(".when-selection-disabled").hide();
      gallery.element.find(".image .image-options").hide();
    } else {
      gallery.element.find(".unselected-but-selectable").hide();
      gallery.element.find(".when-selection-enabled").hide();
      gallery.element.find(".when-selection-disabled").show();
    }
  };

  return {
    init: function() {
      gallery.preloadImages();
      gallery.setupEvents();
      gallery.updateUi();
    },

    addImage: function(url, id, isCover) {
      gallery.addImage(url, id, isCover);
    },

    resetImagesOrder: function() {
      gallery.element.find("input.js-image-input").remove();
      gallery.refreshImagesFormInputs();
    },

    attachable: function() {
      return {
        type: gallery.element.data("attachable-type"),
        id:   gallery.element.data("attachable-id")
      };
    }
  }
}
