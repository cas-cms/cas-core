module Cas
  class Content < ApplicationRecord
    include ::PgSearch
    extend ::FriendlyId

    friendly_id :title, use: :slugged
    acts_as_taggable

    serialize :metadata

    belongs_to :section
    belongs_to :category, optional: true
    belongs_to :author, class_name: "::Cas::User"

    has_many :images,
      ->{ where(media_type: :image).order("cas_media_files.order ASC") },
      class_name: "::Cas::MediaFile", as: :attachable, dependent: :destroy
    has_many :attachments,
      ->{ where(media_type: :attachment).order("cas_media_files.order ASC") },
      class_name: "::Cas::MediaFile", as: :attachable, dependent: :destroy
    has_many :activities, as: :subject

    has_one :site, through: :section
    has_one :cover_image,
      ->{ where(media_type: :image, cover: true) },
      class_name: "::Cas::MediaFile", as: :attachable

    validates :title, presence: true

    before_validation :set_published_at
    before_save :cache_tags

    scope :published, ->{ where(published: true) }

    pg_search_scope :search, ->(query) do
      {
        query: query,
        against: [:title, :text, :location, :tags_cache],
        order_within_rank: "cas_contents.published_at DESC"
      }
    end

    def date_year
      date.year
    end

    def metadata
      if self[:metadata].is_a?(String)
        JSON.parse(self[:metadata])
      else
        super
      end
    end

    private

    def set_published_at
      if published_at.blank? && published
        self.published_at = Time.now
      end
    end

    # so we can fulltext search appropriatelly with pg_search
    def cache_tags
      category_name = "#{category.name if category.present?}"
      self.tags_cache = (tag_list + category_name).flatten.join(", ")
    end
  end
end
