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
      fill_in 'content_title', with: content.title
      fill_in 'content_summary', with: content.summary
      fill_in 'content_text', with: content.text
      fill_in 'content_tag_list', with: 'tag1 tag2'

      expect do
        click_on 'submit'
      end.to change(::Cas::Content, :count).by(1)

      last_content = Cas::Content.last
      expect(last_content.title).to eq content.title
      expect(last_content.summary).to eq content.summary
      expect(last_content.text).to eq content.text
      expect(last_content.tag_list).to match_array ['tag1', 'tag2']
    end

    scenario "I edit a content in a section news" do
      click_link "manage-section-#{section.id}"
      click_link "edit-content-#{content.id}"

      fill_in 'content[title]', with: 'new title 2'
      fill_in 'content_tag_list', with: 'edited-tag1 tag2'

      expect do
        click_on 'submit'
      end.to_not change(::Cas::Content, :count)

      expect(current_path).to eq section_contents_path(section)
      expect(page).to have_content 'new title 2'

      last_content = Cas::Content.last
      expect(last_content.title).to eq 'new title 2'
      expect(last_content.tag_list).to match_array ['edited-tag1', 'tag2']
    end
  end
end
