module Cas
  class Site < ApplicationRecord
    extend ::FriendlyId
    friendly_id :name, use: :slugged

    has_many :sections, dependent: :destroy
  end
end
