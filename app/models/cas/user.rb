module Cas
  class User < ApplicationRecord
    ROLES = %w[admin autor jornalista ].freeze

    before_save { self.email = email.downcase }
    validates :name, presence: true, length: { maximum: 50 }
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 },
                           format: { with: VALID_EMAIL_REGEX },
                           uniqueness: { case_sensitive: false }
    validates :password, presence: true, length: { minimum: 6 }

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

    def admin?
      roles.include?("admin")
    end

    private

    def email_required?
      false
    end
  end
end
