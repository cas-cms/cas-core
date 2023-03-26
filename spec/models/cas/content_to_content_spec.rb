require 'rails_helper'

module Cas
  RSpec.describe ContentToContent, type: :model do
    describe "callbacks" do
      describe "before_save" do
        let!(:section) { create(:section, :news) }
        let!(:content) { create(:content, section: section) }

        let!(:related_section) { create(:section, :biography) }
        let!(:related_content) { create(:content, section: related_section) }

        it "figures out the section type" do
          new_relationship = Cas::ContentToContent.create!(
            cas_content_id: content.id,
            cas_other_content_id: related_content.id,
          )

          expect(new_relationship.related_section).to eq(related_section)
        end
      end
    end
  end
end
