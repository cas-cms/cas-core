module Cas
  class User < ApplicationRecord
    devise :database_authenticatable, #:recoverable,
           :rememberable, :trackable, :validatable

    has_many :contents
    has_many :files, class_name: Cas::MediaFile, as: :attachable
  end
end
