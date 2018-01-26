module Cas
  class Activity < ApplicationRecord
    belongs_to :site
    belongs_to :person
    belongs_to :subject, polymorphic: true
  end
end
