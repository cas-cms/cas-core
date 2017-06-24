module Cas
  class Content < ApplicationRecord
    belongs_to :section
    belongs_to :category
    belongs_to :author, class_name: Cas::User
    has_many :images, ->{ where(media_type: :image) }, class_name: Cas::MediaFile, as: :attachable
  end
end
