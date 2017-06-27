module Cas
  class User < ApplicationRecord
    devise :database_authenticatable, #:recoverable,
           :rememberable, :trackable, :validatable

    has_many :contents
    has_many :files, class_name: Cas::MediaFile, as: :attachable

    def self.find_for_database_authentication(warden_conditions)
      conditions = warden_conditions.dup
      sql = where(["lower(login) = :value OR lower(email) = :value", {
        value: conditions[:email].downcase
      }])
      sql.first
    end

    private

    def email_required?
      false
    end
  end
end
