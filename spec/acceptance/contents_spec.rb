require "rails_helper"

RSpec.feature 'Contents' do
  let(:admin)  { create(:user, :admin, sites: [site]) }
  let(:editor) { create(:user, :editor, sites: [site]) }
  let(:writer) { create(:user, :writer, sites: [site]) }

  let!(:site) { create(:site) }
  let!(:section) { create(:section, site: site) }
  let!(:survey_section) { create(:section, :survey, site: site) }
  let!(:agenda_section) { create(:section, :agenda, site: site) }
  let!(:category) { create(:category, section: section) }
  let!(:content) { create(:content, section: section, author: user, category: category) }
  let!(:someone_else_content) { create(:content, section: section, author: someone_else, category: category) }
  let!(:file_orphan) { create(:file, attachable: nil) }

  background do
    login(user)
    visit root_path
  end

  context 'As admin' do
    let(:user) { admin }
    let(:someone_else) { editor }

    context 'when visit news' do
      scenario 'I create a content in a section news' do
        visit site_sections_path(site)
        click_link "new-content-#{section.id}"

        select('sports', from: 'content_category_id')
        fill_in 'content_title', with: 'new content'
        fill_in 'content_summary', with: 'summary'
        fill_in 'content_text', with: 'text'
        fill_in 'content_tag_list', with: 'tag1.1 tag1.2,tag2'

        find("#test_image_1", visible: false).set(file_orphan.id)

        expect do
          click_on 'submit'
        end.to change(::Cas::Content, :count).by(1)

        last_content = Cas::Content.where(title: 'new content').first
        expect(last_content.title).to eq "new content"
        expect(last_content.summary).to eq 'summary'
        expect(last_content.text).to eq 'text'
        expect(last_content.tag_list).to match_array ['tag1.1 tag1.2', 'tag2']
        expect(last_content.images).to match_array [file_orphan]

        activity = Cas::Activity.last
        expect(activity.user).to eq user
        expect(activity.site).to eq site
        expect(activity.event_name).to eq 'create'
      end

      scenario "I edit a content in a section news" do
        click_link "manage-section-#{section.id}"
        click_link "edit-content-#{content.id}"

        fill_in 'content[title]', with: 'new title 2'
        fill_in 'content_tag_list', with: 'edited-tag1.1 edited-tag1.2,tag2'
        find("#test_image_1", visible: false).set(file_orphan.id)

        expect(content.images).to be_blank

        expect do
          click_on 'submit'
        end.to_not change(::Cas::Content, :count)

        expect(current_path).to eq site_section_contents_path(site, section)
        expect(page).to have_content 'new title 2'

        expect(content.reload.images).to be_present
        expect(content.title).to eq 'new title 2'
        expect(content.tag_list).to match_array ['edited-tag1.1 edited-tag1.2', 'tag2']
      end

      scenario "I edit the order of the images" do
        image1 = create(:file, order: 1, attachable: content, cover: true)
        image2 = create(:file, order: 2, attachable: content, cover: false)
        image3 = create(:file, order: 3, attachable: nil)
        attachment1 = create(:file, order: 1, attachable: content)
        attachment2 = create(:file, order: 2, attachable: content)
        attachment3 = create(:file, order: 3, attachable: nil)

        click_link "manage-section-#{section.id}"
        click_link "edit-content-#{content.id}"

        find("#test_image_1", visible: false).set(image2.id)
        find("#test_image_2", visible: false).set(image3.id)
        find("#test_image_3", visible: false).set(image1.id)
        find("#test_image_cover_id", visible: false).set(image2.id)
        find("#test_attachment_1", visible: false).set(attachment2.id)
        find("#test_attachment_2", visible: false).set(attachment3.id)
        find("#test_attachment_3", visible: false).set(attachment1.id)

        expect(image1).to be_cover
        expect(image2).to_not be_cover
        click_on 'submit'

        expect(image1.reload.order).to eq 3
        expect(image2.reload.order).to eq 1
        expect(image3.reload.order).to eq 2
        expect(image3.attachable).to eq content
        expect(image2).to be_cover
        expect(image1).to_not be_cover
        expect(attachment1.reload.order).to eq 3
        expect(attachment2.reload.order).to eq 1
        expect(attachment3.reload.order).to eq 2
        expect(attachment3.attachable).to eq content

        click_link "edit-content-#{content.id}"
        find("#test_image_1", visible: false).set(image2.id)
        find("#test_image_2", visible: false).set(image3.id)
        find("#test_image_3", visible: false).set(image1.id)
        # new file as cover
        find("#test_image_cover_id", visible: false).set(image1.id)
        click_on 'submit'
        expect(image1.reload).to be_cover
        expect(image2.reload).to_not be_cover
      end

      context 'invalid data' do
        scenario "I see errors on the screen" do
          visit site_sections_path(site)
          click_link "new-content-#{section.id}"

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

    context 'when managing a survey' do
      let!(:survey) { create(:content, :survey, section: survey_section) }

      scenario "I create questions" do
        visit site_sections_path(site)
        click_link "new-content-#{survey_section.id}"

        fill_in :content_title, with: "Survey title"
        fill_in :question_1_text, with: "question 1"
        fill_in :question_2_text, with: "question 2"
        fill_in :question_3_text, with: "question 3"
        fill_in :question_4_text, with: ""
        check :content_published

        expect {
          click_on 'submit'
        }.to change(::Cas::Content, :count).by(1)

        expect(survey).to be_published

        new_survey = survey_section.contents.where.not(id: survey.id).first!
        expect(new_survey.metadata).to eq({
          "survey" => {
            "questions" => {
              "0" => {
                "text" => "question 1",
                "votes" => "0"
              },
              "1" => {
                "text" => "question 2",
                "votes" => "0"
              },
              "2" => {
                "text" => "question 3",
                "votes" => "0"
              },
              "3" => {
                "text" => "",
                "votes" => "0"
              }
            }
          }
        })
      end

      scenario "I edit questions" do
        visit site_sections_path(site)
        click_link "manage-section-#{survey_section.id}"
        click_link "edit-content-#{survey.id}"

        expect(find("#question_1_text").value).to eq "question 1"
        expect(find("#question_2_text").value).to eq "question 2"
        expect(find("#question_3_text").value).to eq "question 3"
        expect(find("#question_4_text").value).to eq ""

        fill_in :content_title, with: "Survey title"
        fill_in :question_1_text, with: "edited question 1"
        fill_in :question_2_text, with: "question 2"
        fill_in :question_3_text, with: ""
        fill_in :question_4_text, with: "new question"
        uncheck :content_published

        expect {
          click_on 'submit'
        }.to change(::Cas::Content, :count).by(0)

        survey.reload
        expect(survey).to_not be_published
        expect(survey.metadata).to eq({
          "survey" => {
            "questions" => {
              "0" => {
                "text" => "edited question 1",
                "votes" => "1"
              },
              "1" => {
                "text" => "question 2",
                "votes" => "2"
              },
              "2" => {
                "text" => "",
                "votes" => "3"
              },
              "3" => {
                "text" => "new question",
                "votes" => "0"
              }
            }
          }
        })
      end
    end

    context 'when visiting the agenda' do
      let!(:section) { create(:section, name: 'agenda', slug: 'agenda', site: site) }
      let(:new_content) { section.contents.reload.where(title: "new content").first }

      before do
        visit site_sections_path(site)

        click_link "new-content-#{section.id}"
        fill_in 'content_title', with: "new content"
        fill_in 'content_location', with: "new location"
        select '13',  from: 'content_date_3i'
        select 'July', from: 'content_date_2i'
        select Time.now.year.to_s, from: 'content_date_1i'
        fill_in 'content_text', with: "new content text"

        expect do
          click_on 'submit'
        end.to change(::Cas::Content, :count).by(1)
      end

      scenario 'I create a content in a section agenda' do
        last_content = Cas::Content.where(title: 'new content').first
        expect(last_content.title).to eq "new content"
        expect(last_content.location).to eq "new location"
        expect(last_content.text).to eq "new content text"
      end
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
      visit edit_site_section_content_path(site, someone_else_content.section, someone_else_content)
    end
  end

  context 'As writer' do
    let(:user) { writer }
    let(:someone_else) { admin }

    scenario 'I am able to see only my own content' do
      expect(page).to have_content "news"
      expect(page).to_not have_content "Agenda"
      expect(page).to have_content "Survey"

      click_link "manage-section-#{section.id}"
      expect(page).to have_content content.title
      expect(page).to_not have_content someone_else_content.title
    end

    scenario "I am not able to go to edit someone else's content by id" do
      expect do
        visit edit_site_section_content_path(site, someone_else_content.section, someone_else_content)
      end.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
