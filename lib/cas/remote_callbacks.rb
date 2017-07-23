module Cas
  class RemoteCallbacks
    INITIAL_SETUP ||= {
      # Class to be called after image was saved.
      after_file_upload: ->(file) { }
    }.freeze

    @@callbacks ||= INITIAL_SETUP

    def self.reset
      @@callbacks ||= INITIAL_SETUP
    end

    def self.callbacks=(callbacks_hash)
      @@callbacks = callbacks_hash
    end

    def self.callbacks
      @@callbacks
    end
  end
end
