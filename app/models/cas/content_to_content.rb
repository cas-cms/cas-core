module Cas
  class ContentToContent < ApplicationRecord
    belongs_to :content, foreign_key: :cas_content_id
    belongs_to :related_section, foreign_key: :cas_other_section_id, class_name: "Cas::Section"
    belongs_to :related_content, foreign_key: :cas_other_content_id, class_name: "Cas::Content"

    before_validation :set_related_section

    private

    def set_related_section
      return true if related_section.present?
      self.related_section = related_content.section
    end
  end
end
