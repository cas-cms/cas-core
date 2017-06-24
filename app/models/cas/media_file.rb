module Cas
  class MediaFile < ApplicationRecord
    belongs_to :attachable, polymorphic: true

    def url
      "#{ENV.fetch("CDN_HOST")}#{path}"
    end
  end
end
