module Cas
  class MediaFile < ApplicationRecord
    include FileUploader::Attachment.new(:file)

    class UnknownPath < StandardError; end

    belongs_to :attachable, polymorphic: true
    belongs_to :author, class_name: "Cas::User"

    before_validation :set_media_type

    scope :cover, ->{ where(cover: true) }
    scope :non_cover, ->{ where(cover: false) }

    def url(use_cdn: true)
      cdn = ENV.fetch("CDN_HOST", nil) if use_cdn
      if path.present?
        [cdn, path].join("/").gsub(/([^:])\/\//, '\1/')
      elsif JSON.parse(file_data).present?
        if cdn.present?
          file_url(host: cdn)
        else
          file_url
        end
      else
        raise UnknownPath
      end
    end

    private

    def set_media_type
      self.media_type = mime_type.scan(/([a-z]*)\/.*/)[0][0]
    end
  end
end
