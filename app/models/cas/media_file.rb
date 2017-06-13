module Cas
  class MediaFile < ApplicationRecord
  	belongs_to :attachable, polymorphic: true
  end
end
