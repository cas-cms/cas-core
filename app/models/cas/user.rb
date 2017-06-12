module Cas
  class User < ApplicationRecord
    has_many :contents
  end
end
