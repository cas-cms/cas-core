require 'rails_helper'

module Cas
  RSpec.describe Activity, type: :model do
    describe "callbacks" do
      describe "cache_description" do
        let(:admin)  { create(:user, :admin, sites: [site2]) }
        let(:editor) { create(:user, :editor, sites: [site2]) }
        let(:writer) { create(:user, :writer, sites: [site2]) }

        let(:site1) { create(:site, name: "mysite1") }
        let(:site2) { create(:site, name: "mysite") }
        let(:site3) { create(:site, name: "mysite3") }
        let(:section1) { create(:section, site: site1) }
        let(:section2) { create(:section, site: site2) }
        let(:section3) { create(:section, site: site3) }
        let(:content1) { create(:content, section: section1) }
        let(:content2) { create(:content, section: section2) }
        let(:content3) { create(:content, section: section3) }
        let(:activity1) { create(:activity, site: site1, subject: content1, user: admin) }
        let(:activity2) { create(:activity, site: site2, subject: section1, user: editor) }
        let(:activity3) { create(:activity, site: site3, subject: content3, user: writer) }

        it "caches user and subject" do
          expect(activity1.user_description).to eq("John Wayne (admin)")
          expect(activity1.subject_description).to eq("Content 1")
          expect(activity2.user_description).to eq("John Wayne")
          expect(activity2.subject_description).to eq("news")
        end
      end
    end
  end
end
