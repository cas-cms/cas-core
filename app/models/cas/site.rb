module Cas
  class Site < ApplicationRecord
    has_many :sections, dependent: :destroy
  end
end
