require 'rails_helper'

describe Cas::FormHelper, type: :helper do
  describe "#autocomplete_for_has_many" do
    let(:site) { create(:site) }
    let!(:related_section) { create(:section, :biography, site: site) }
    # Why will it show these contents? Because the YAML file has specified that
    # news has_many biography
    let!(:related_content1) { create(:content, section: related_section) }
    let!(:related_content2) { create(:content, section: related_section) }

    before do
      @section = create(:section, :news, site: site)
    end

    it "returns a hash with possible values" do
      @content = create(:content, section: @section)

      expect(helper.autocomplete_for_has_many).to match_array([
        { id: related_content1.id, title: "#{related_content1.title} (Biography)" },
        { id: related_content2.id, title: "#{related_content2.title} (Biography)" },
      ])
    end
  end
end
