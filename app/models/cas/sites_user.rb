module Cas
  class SitesUser < ApplicationRecord
    belongs_to :site
    belongs_to :user
    belongs_to :owner, class_name: 'Cas::User'
  end
end
