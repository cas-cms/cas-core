require "rails_helper"

RSpec.feature 'Activities' do
  let(:admin)  { create(:user, :admin, sites: [site2]) }
  let(:editor) { create(:user, :editor, sites: [site2]) }
  let(:writer) { create(:user, :writer, sites: [site2]) }

  let!(:site1) { create(:site, slug: "mysite1") }
  let!(:site2) { create(:site, slug: "mysite") }
  let!(:site3) { create(:site, slug: "mysite3") }
  let!(:content1) { create(:content) }
  let!(:content2) { create(:content) }
  let!(:content3) { create(:content) }
  let!(:activity1) { create(:activity, site: site1, subject: content1, user: admin) }
  let!(:activity2) { create(:activity, site: site2, subject: content2, user: editor) }
  let!(:activity3) { create(:activity, site: site3, subject: content3, user: writer) }

  background do
    login(user)
    visit root_path
  end

  context 'As editor' do
    let(:user) { editor }

    scenario 'I am able to see activities from the same website' do
      click_link "go-to-activities"
      expect(page).to have_content editor.name
      expect(page).to have_content content2.title

      expect(page).to_not have_content content1.title
      expect(page).to_not have_content content3.title
    end
  end
end
