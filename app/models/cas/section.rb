module Cas
  class Section < ApplicationRecord
    belongs_to :site
    has_many :contents
    has_many :categories
  end
end
