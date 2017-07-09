function CasImage(element, gallery) {
  var image = this;
  image.element = element;
  image.gallery = gallery;

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
    }
  }
}

function CasImageGallery(options) {
  var gallery = this;
  gallery.element = options.element;
  gallery.isSelectionEnabled = options.selectionEnabled || false;

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

  gallery.deleteImages = function() {
    var ids = [];
    ids = gallery.getSelectedItems().map(function(index, imageElement) {
      var image = new CasImage(imageElement, gallery);
      return String(image.recordId());
    });
    options.onDelete(ids);
  };

  gallery.setupEvents = function() {
    options.element.find(".image-container").on("click", function() {
      var image = new CasImage($(this), gallery);
      image.click();
      gallery.updateUi();
    });

    options.element.find(".js-toggle-selection").on("click", function() {
      gallery.toggleSelection();
    });

    options.element.find(".js-delete-image").on("click", function() {
      gallery.deleteImages();
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
      gallery.setupEvents();
      gallery.updateUi();
    }
  }
}
