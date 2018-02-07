module Cas
  class Site < ApplicationRecord
    extend ::FriendlyId
    friendly_id :name, use: :slugged

    has_many :sections, dependent: :destroy
    has_many :people_site, class_name: '::Cas::PeopleSite'
    has_many :people, through: :people_site
  end
end
