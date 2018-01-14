module Cas
  class Activity < ApplicationRecord
    belongs_to :site
    belongs_to :user
    belongs_to :subject, polymorphic: true

  end
end
