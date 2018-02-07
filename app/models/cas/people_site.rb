module Cas
  class PeopleSite < ApplicationRecord
    belongs_to :site
    belongs_to :person
    belongs_to :owner, class_name: '::Cas::Person'
  end
end
