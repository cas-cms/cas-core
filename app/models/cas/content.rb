module Cas
  class Content < ApplicationRecord
    extend ::FriendlyId
    friendly_id :title, use: :slugged
    acts_as_taggable

    belongs_to :section
    belongs_to :category
    belongs_to :author, class_name: Cas::User
    has_many :images, ->{ where(media_type: :image).order("cas_media_files.order ASC") }, class_name: Cas::MediaFile, as: :attachable, dependent: :destroy
    has_one :cover_image, ->{ where(media_type: :image, cover: true) }, class_name: Cas::MediaFile, as: :attachable

    validates :title, presence: true

    def date_year
      date.year
    end
  end
end
