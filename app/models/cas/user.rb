module Cas
  class User < ApplicationRecord
    ROLES = %w[admin editor writer].freeze

    devise :database_authenticatable, #:recoverable,
           :rememberable, :trackable, :validatable

    has_many :contents
    has_many :files, class_name: 'Cas::MediaFile', as: :attachable
    has_many :sites_users, class_name: 'Cas::SitesUser'
    has_many :sites, through: :sites_users

    validates :name, presence: true, length: { maximum: 50 }
    validates :email, presence: true, length: { maximum: 255 },
                           uniqueness: { case_sensitive: false }
    validates :password, presence: true, length: { minimum: 6 }, on: :create, allow_blank: true

    before_save { self.email = email.to_s.downcase }

    def self.find_for_database_authentication(warden_conditions)
      conditions = warden_conditions.dup
      sql = where(["lower(login) = :value OR lower(email) = :value", {
        value: conditions[:email].downcase
      }])
      sql.first
    end

    def admin?
      roles.include?("admin")
    end

    def editor?
      roles.include?("editor")
    end

    private

    def email_required?
      false
    end
  end
end
