module Cas
  class Site < ApplicationRecord
    extend ::FriendlyId
    friendly_id :name, use: :slugged

    has_many :sections, dependent: :destroy
    has_many :sites_users, class_name: '::Cas::SitesUser'
    has_many :users, through: :sites_users
  end
end
