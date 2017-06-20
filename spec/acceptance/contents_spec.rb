require "rails_helper"

Rspec.feature 'Contents' do
  let(:user) { create(:user) }
  let!(:section) { create(:section) }
  let!(:category) { create(:category, section: section) }
  let!(:content) { create(:content) }

  context 'As admin' do
    background do
      login(user)
    end
  end

  scenario 'I create a content' do
    
  end

  context 'As admin in the contents' do
    background do
      visit section_contents_path(@section.id)
    end

    scenario 'I can see form for new contents' do
      expect(page).to have_content 'Listing Contents'
    end

    scenario 'I can create a new content' do
      fill_in 
    end
  end
end
