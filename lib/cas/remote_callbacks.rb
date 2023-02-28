module Cas
  class RemoteCallbacks
    INITIAL_SETUP ||= {
      # Process images here and return a hash
      #
      #   {
      #     small:  small_image,
      #     medium: medium_image,
      #     big:    big_image
      #   }
      #
      # `original` should not be present after Shrine 3.0. If it is not, we will
      # merge it afterwards automatically.
      uploaded_image_versions: ->(original) {
        {}
      },

      # Class to be called after image was saved.
      after_file_upload: ->(file) { }
    }.freeze

    @@callbacks ||= INITIAL_SETUP

    def self.reset
      @@callbacks ||= INITIAL_SETUP
    end

    def self.callbacks=(callbacks_hash)
      @@callbacks = INITIAL_SETUP.merge(callbacks_hash)
    end

    def self.callbacks
      @@callbacks
    end
  end
end
