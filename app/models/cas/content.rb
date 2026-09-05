module Cas
  class Content < ApplicationRecord
    include ::PgSearch
    extend ::FriendlyId

    friendly_id :title, use: :slugged
    acts_as_taggable

    serialize :metadata

    belongs_to :section
    has_one :site, through: :section
    belongs_to :category
    belongs_to :author, class_name: "::Cas::User"
    has_many :images, ->{ where(media_type: :image).order("cas_media_files.order ASC") }, class_name: "::Cas::MediaFile", as: :attachable, dependent: :destroy
    has_many :attachments, ->{ where(media_type: :attachment).order("cas_media_files.order ASC") }, class_name: "::Cas::MediaFile", as: :attachable, dependent: :destroy
    has_many :activities, as: :subject
    has_one :cover_image, ->{ where(media_type: :image, cover: true) }, class_name: "::Cas::MediaFile", as: :attachable

    validates :title, presence: true

    before_validation :set_published_at
    before_save :cache_tags

    scope :published, ->{ where(published: true) }

    # published_at is filled when a content is first saved as published. Rows
    # that predate the column or were published outside the model have none,
    # so ordering and filtering by publication date fall back to created_at.
    # The index in db/migrate/20260905120000 uses the same expression.
    PUBLICATION_DATE_SQL = "COALESCE(cas_contents.published_at, cas_contents.created_at)".freeze

    scope :published_since, ->(time) { where("#{PUBLICATION_DATE_SQL} >= ?", time) }

    scope :by_publication_date, ->(direction = :desc) {
      sql_direction = direction.to_s.upcase
      raise ArgumentError, "direction must be :asc or :desc" unless %w[ASC DESC].include?(sql_direction)

      order(Arel.sql("#{PUBLICATION_DATE_SQL} #{sql_direction}, cas_contents.created_at #{sql_direction}"))
    }

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

    def publication_date
      published_at || created_at
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
