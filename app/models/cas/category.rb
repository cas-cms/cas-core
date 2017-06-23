module Cas
  class Category < ApplicationRecord
    belongs_to :section
    has_many :contents
  end
end
