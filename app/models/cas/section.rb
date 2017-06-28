module Cas
  class Section < ApplicationRecord
    extend ::FriendlyId
    friendly_id :name, use: :slugged

    belongs_to :site
    has_many :contents, dependent: :destroy
    has_many :categories, dependent: :destroy
  end
end
