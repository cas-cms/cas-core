module Cas
  class Content < ApplicationRecord
    belongs_to :section
    belongs_to :user
    has_many :files, class_name: Cas::MediaFile, as: :attachable
  end
end
