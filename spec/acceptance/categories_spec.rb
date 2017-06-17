require 'rails_helper'

RSpec.feature 'Categories' do
  let(:user) { create(:user) }
  let!(:section) { create(:section) }

  context 'As admin' do
    background do
      login(user)
    end

    scenario "I create a categories in a section" do
      expect(current_path).to eq cas.root_path
      click_link "manage-section-#{section.id}"
      click_link 'manage-categories'
      click_link 'new-category'

      expect(Cas::Category.count).to eq 0
      fill_in 'category_name', with: user.email
      click_on 'submit'

      expect(Cas::Category.count).to eq 1

      expect(current_path).to eq section_categories_path(section)
    end
  end
end
