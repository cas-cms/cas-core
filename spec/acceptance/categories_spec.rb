require 'rails_helper'

RSpec.feature 'Categories' do
  let(:user) { create(:user) }
  let!(:section) { create(:section) }
  let!(:category) { create(:category, section: section) }

  context 'As admin' do
    background do
      login(user)
    end

    scenario "I create a category in a section" do
      expect(current_path).to eq cas.root_path
      click_link "manage-section-#{section.id}"
      click_link 'manage-categories'
      click_link 'new-category'

      fill_in 'category_name', with: user.email

      expect do
        click_on 'submit'
      end.to change(::Cas::Category, :count).by(1)

      expect(current_path).to eq section_categories_path(section)
    end

    scenario "I edit a category in a section" do
      click_link "manage-section-#{section.id}"
      click_link 'manage-categories'
      click_link "edit-category-#{category.id}"

      fill_in 'category_name', with: 'old category'

      expect do
        click_on 'submit'
      end.to_not change(::Cas::Category, :count)

      expect(current_path).to eq section_categories_path(section)
      expect(page).to have_content 'old category'
    end
  end
end
