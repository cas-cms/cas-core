require 'rails_helper'

feature "Content management", :type => :feature do
  # before :each do
  #   User.make(email: 'user@example.com', password: 'password')
  # end

  describe "sections listing" do
    scenario "I see all sections" do

      subject = Cas::Setup.new("spec/fixtures/cas.yml") 
      subject.install
      visit '/cas'

      news = Cas::Section.where(name: 'Notícias').first
      expect(page).to have_content 'Notícias'
      within "#section-#{news.id}" do
        click_link('Novo')
      end

      # puts section_contents_path(news)
      # expect(current_path).to eq new_section_content_path(news)
      fill_in('content_title', with: 'Noticia 1')
      fill_in('content_text', with: 'Texto da noticia 1')
      click_button('Salvar')
      expect(current_path).to eq section_contents_path(news)
      expect(page).to have_content 'Noticia 1'


    end
  end
end