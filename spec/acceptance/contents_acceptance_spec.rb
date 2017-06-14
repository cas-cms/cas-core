require "rails_helper"

feature "Admin/Sections/Contents" do
  background do
    @user = FactoryGirl.create(:user)
    @site = FactoryGirl.create(:site)
    @section = FactoryGirl.create(:section)
    @content = FactoryGirl.create(:content)
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
