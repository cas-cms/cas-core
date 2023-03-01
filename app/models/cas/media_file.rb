module Cas
  class MediaFile < ApplicationRecord
    include FileUploader::Attachment.new(:file) # This is for the Shrine gem

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

      # Shrine gem uses `file_data` because `file` is the name we specified for
      # the Attachment at the top of this model.
      elsif JSON.parse(file_data).present?
        params = {
          public: true
        }
        params[:host] = cdn if cdn.present?

        # With Shrine, the default image version is :original. Other versions
        # are called derivatives. The `file_url` method expects a derivative
        # name as first argument.
        #
        # When we pass :original, it just returns `nil` because the main file is
        # not considered a derivative. If we had something like :larger, then
        # that would be the argument.
        url = if version.to_sym == :original
                file_url(params)
              else
                file_url(version, params)
              end

        # Amazon S3 has URLs that include some query strings like signatures
        # which we don't want to include in URLs.
        url&.gsub(/\?.*/, "")
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
