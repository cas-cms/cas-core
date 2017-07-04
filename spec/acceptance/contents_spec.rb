require "rails_helper"

RSpec.feature 'Contents' do
  let(:admin)  { create(:user, :admin) }
  let(:editor) { create(:user, :editor) }
  let(:writer) { create(:user, :writer) }

  let!(:section) { create(:section) }
  let!(:category) { create(:category, section: section) }
  let!(:content) { create(:content, section: section, author: user, category: category) }
  let!(:someone_else_content) { create(:content, section: section, author: someone_else, category: category) }
  let!(:file_orphan) { create(:file, attachable: nil) }

  background do
    login(user)
  end

  context 'As admin' do
    let(:user) { admin }
    let(:someone_else) { editor }

    scenario 'I create a content in a section news' do
      visit sections_path
      click_link 'new-content'

      select('sports', from: 'content_category_id')
      fill_in 'content_title', with: 'new content'
      fill_in 'content_summary', with: 'summary'
      fill_in 'content_text', with: 'text'
      fill_in 'content_tag_list', with: 'tag1 tag2'

      find("#test_file_1", visible: false).set(file_orphan.id)

      expect do
        click_on 'submit'
      end.to change(::Cas::Content, :count).by(1)

      last_content = Cas::Content.where(title: 'new content').first
      expect(last_content.title).to eq "new content"
      expect(last_content.summary).to eq 'summary'
      expect(last_content.text).to eq 'text'
      expect(last_content.tag_list).to match_array ['tag1', 'tag2']
      expect(last_content.images).to match_array [file_orphan]
    end

    scenario "I edit a content in a section news" do
      click_link "manage-section-#{section.id}"
      click_link "edit-content-#{content.id}"

      fill_in 'content[title]', with: 'new title 2'
      fill_in 'content_tag_list', with: 'edited-tag1 tag2'
      find("#test_file_1", visible: false).set(file_orphan.id)

      expect(content.images).to be_blank

      expect do
        click_on 'submit'
      end.to_not change(::Cas::Content, :count)

      expect(current_path).to eq section_contents_path(section)
      expect(page).to have_content 'new title 2'

      expect(content.reload.images).to be_present
      expect(content.title).to eq 'new title 2'
      expect(content.tag_list).to match_array ['edited-tag1', 'tag2']
    end

    context 'invalid data' do
      scenario "I see errors on the screen" do
        visit sections_path
        click_link 'new-content'

        select('sports', from: 'content_category_id')

        expect do
          click_on 'submit'
        end.to change(::Cas::Content, :count).by(0)

        expect(page).to have_content "can't be blank"
      end
    end

    scenario 'I delete a content in a section news' do
      click_link "manage-section-#{section.id}"

      expect(::Cas::Content.count).to eq 2
      expect(page).to have_content content.title

      click_link "delete-content-#{content.id}"

      expect(::Cas::Content.count).to eq 1
      expect(page).to_not have_content content.title
    end

    scenario 'I am able to see everyones content' do
      click_link "manage-section-#{section.id}"
      expect(page).to have_content content.title
      expect(page).to have_content someone_else_content.title
    end
  end

  context 'As editor' do
    let(:user) { editor }
    let(:someone_else) { admin }

    scenario 'I am able to see everyones content' do
      click_link "manage-section-#{section.id}"
      expect(page).to have_content content.title
      expect(page).to have_content someone_else_content.title
    end

    scenario "I am able to go to edit someone else's content by id" do
      visit edit_section_content_path(someone_else_content.section, someone_else_content)
    end
  end

  context 'As writer' do
    let(:user) { writer }
    let(:someone_else) { admin }

    scenario 'I am able to see only my own content' do
      click_link "manage-section-#{section.id}"
      expect(page).to have_content content.title
      expect(page).to_not have_content someone_else_content.title
    end

    scenario "I am not able to go to edit someone else's content by id" do
      expect do
        visit edit_section_content_path(someone_else_content.section, someone_else_content)
      end.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
