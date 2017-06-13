module Cas
  class User < ApplicationRecord
    has_many :contents
    has_many :files, class_name: Cas::MediaFile, as: :attachable
  end
end
