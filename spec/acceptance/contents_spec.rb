require "rails_helper"

RSpec.feature 'Contents' do
  let(:user) { create(:user) }
  let!(:section) { create(:section) }
  let!(:category) { create(:category, section: section) }
  let!(:content) { create(:content, section: section, author: user, category: category) }

  context 'As admin' do
    background do
      login(user)
    end

    scenario 'I create a content in a section news' do
      visit sections_path
      click_link 'new-content'

      select('sports', from: 'content_category_id')
      fill_in 'content[title]', with: content.title
      fill_in 'content[summary]', with: content.summary
      fill_in 'content[text]', with: content.text

      expect do
        click_on 'submit'
      end.to change(::Cas::Content, :count).by(1)
    end

    scenario "I edit a content in a section news" do
      click_link "manage-section-#{section.id}"
      click_link "edit-content-#{content.id}"

      fill_in 'content[title]', with: 'new title 2'

      expect do
        click_on 'submit'
      end.to_not change(::Cas::Content, :count)

      expect(current_path).to eq section_contents_path(section)
      expect(page).to have_content 'new title 2'
    end
  end
end
