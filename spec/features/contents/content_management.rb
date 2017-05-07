require 'rails_helper'

feature "Content management", :type => :feature do

  describe "As an admin" do
    scenario "I see all sections" do

      subject = Cas::Setup.new("spec/fixtures/cas.yml") 
      subject.install
      visit '/cas'
      expect(page).to have_content 'Notícias'
    end

    scenario "I create content" do
      subject = Cas::Setup.new("spec/fixtures/cas.yml") 
      subject.install
      news = Cas::Section.where(name: 'Notícias').first
      visit '/cas'
      within "#section-#{news.id}" do
        click_link('Novo')
      end
      fill_in('content_title', with: 'Noticia 1')
      fill_in('content_text', with: 'Texto da noticia 1')
      click_button('Salvar')
      expect(current_path).to eq section_contents_path(news)
      expect(page).to have_content 'Noticia 1'
    end

    scenario "I want to edit a content" do
      subject = Cas::Setup.new("spec/fixtures/cas.yml") 
      subject.install

      news = Cas::Section.where(name: 'Notícias').first

      Cas::Content.create!(
        title: "Noticia 2"  , 
        text: "Texto da noticia 2",
        section: news
      )
      visit '/cas'
      within "#section-#{news.id}" do
        click_link('listar')
      end
      expect(page).to have_content 'Noticia 2'
      click_link('Noticia 2')
      expect(find_field('content_title').value).to eq 'Noticia 2'
      expect(find_field('content_text').value).to eq 'Texto da noticia 2'

      fill_in('content_text', with: 'Texto da noticia 2 modificado!')
      click_button('Salvar')
      expect(current_path).to eq section_contents_path(edit_section_content)
      expect(find_field('content_text').value).to eq 'Texto da noticia 2 modificado!'
    end
  end
end