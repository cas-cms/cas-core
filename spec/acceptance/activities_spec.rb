require "rails_helper"

RSpec.feature 'Activities' do
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
  let(:activity2) { create(:activity, site: site2, subject: content2, user: editor) }
  let(:activity3) { create(:activity, site: site3, subject: content3, user: writer) }

  background do
    activity1
    activity2
    activity3
    Capybara.app_host = "http://#{site2.domains.first}"
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
