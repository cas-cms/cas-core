require 'rails_helper'

module Cas
  RSpec.describe Setup do
    describe '#install' do
      context 'when the file is valid' do
        it 'creates sites' do
          expect(Cas::Site.count).to eq 0
          subject = Cas::Setup.new("spec/fixtures/cas.yml") 
          subject.install
          subject.install
          expect(Cas::Site.count).to eq 1
          site = Cas::Site.first
          expect(site.name).to eq "ponet"

        end

        it 'creates sections' do
          expect(Cas::Section.count).to eq 0
          subject = Cas::Setup.new("spec/fixtures/cas.yml") 
          subject.install
          subject.install
          expect(Cas::Section.count).to eq 3
          section = Cas::Section.all
          expect(section[0].name).to eq "Notícias"
          expect(section[0].site.name).to eq "ponet"
          expect(section[0].section_type).to eq "content"
          expect(section[1].name).to eq "Túnel do Tempo"
          expect(section[1].site.name).to eq "ponet"
          expect(section[1].section_type).to eq "content"
          expect(section[2].name).to eq "Biografia"
          expect(section[2].site.name).to eq "ponet"
          expect(section[2].section_type).to eq "content"
        end
      end
      context 'when the file is not valid' do 
        it 'shows error'
        # raise
      
      end
    end
  end
end
