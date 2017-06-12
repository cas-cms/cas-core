module Cas
  class Content < ApplicationRecord
    belongs_to :section
    belongs_to :user
  end
end
