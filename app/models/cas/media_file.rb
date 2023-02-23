module Cas
  class MediaFile < ApplicationRecord
    include FileUploader::Attachment.new(:file)

    class UnknownPath < StandardError; end
    class UnknownFileService < StandardError; end

    belongs_to :attachable, polymorphic: true, optional: true
    belongs_to :author, class_name: "::Cas::User", optional: true

    before_validation :set_media_type
    before_save :set_image_as_unique_cover

    scope :cover, ->{ where(cover: true) }
    scope :non_cover, ->{ where(cover: false) }
    scope :usable, -> { where.not(attachable_id: nil) }

    def site
      attachable.site || raise("Attachable doesn't have a Cas::Site association")
    end

    def url(version:, use_cdn: true)
      cdn = ENV.fetch("CDN_HOST", nil) if use_cdn

      # When `path` is present, it means no gem was used for uploads, therefore
      # the image has to be treat as raw URL.
      if path.present?
        if service.downcase == "s3"
          bucket = ENV.fetch('S3_BUCKET')
          region = ENV.fetch('S3_REGION', "s3")
          if cdn
            host = cdn
          else
            host = "https://s3-#{region}.amazonaws.com/#{bucket}"
          end

          [host, path].join("/").gsub(/([^:])\/\//, '\1/')
        else
          raise UnknownFileService
        end

      # Shrine gem uses `file_data`
      elsif JSON.parse(file_data).present?
        if cdn.present?
          file_url(version.to_sym, host: cdn, public: true)
        else
          file_url(version.to_sym, public: true).gsub(/\?.*/, "")
        end
      else
        raise UnknownPath
      end
    end

    private

    def set_media_type
      if self.media_type.blank?
        nature = mime_type.scan(/([a-z]*)\/.*/)[0][0]
        if nature == 'image'
          self.media_type = 'image'
        else
          self.media_type = 'attachment'
        end
      end
    end

    # Only images can have a `cover`
    def set_image_as_unique_cover
      return unless media_type == 'image'
      cover_file = MediaFile
        .where(attachable: self.attachable, cover: true)
        .where.not(id: id)

      if cover?
        cover_file.update_all(cover: false)
      elsif cover_file.blank?
        self.cover = true
      end
    end
  end
end
