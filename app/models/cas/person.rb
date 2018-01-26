module Cas
  class Person < ApplicationRecord
    ROLES = %w[admin editor writer visitor].freeze

    devise :database_authenticatable, #:recoverable,
           :rememberable, :trackable, :validatable, request_keys: [:domain]

    has_many :contents
    has_many :files, class_name: 'Cas::MediaFile', as: :attachable
    has_many :people_site, class_name: 'Cas::PeopleSite'
    has_many :sites, through: :people_site
    has_many :activities, as: :subject

    validates :name, presence: true, length: { maximum: 50 }
    validates :email, presence: true, length: { maximum: 255 },
                           uniqueness: { case_sensitive: false }
    validates :password, presence: true, length: { minimum: 6 }, on: :create, allow_blank: true

    before_save { self.email = email.to_s.downcase }

    def self.find_for_database_authentication(warden_conditions)
      conditions = warden_conditions.dup
      domain = conditions[:domain]
      domain = ENV["DOMAIN"] if Rails.env.development? && ENV["DOMAIN"].present?
      domain = ::Cas::Site.first.domains.first if domain.to_s =~ /localhost/
      sql = where(["lower(login) = :value OR lower(email) = :value", {
        value: conditions[:email].downcase
      }])
      sql = sql.joins(:sites)
      sql = sql.where("cas_sites.domains::text[] && '{#{domain}}'::text[]")
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
