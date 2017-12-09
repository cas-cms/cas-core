require 'rails_helper'

module Cas
  RSpec.describe Setup do
    describe '#install' do
      context 'when the file is valid' do
        it 'creates sites' do
          expect(Site.count).to eq 0
          subject = Setup.new
          subject.install
          subject.install
          expect(Site.count).to eq 1
          site = Site.first
          expect(site.slug).to eq "mysite"
          expect(site.domains).to eq ["mysite.net"]
          expect(site.name).to eq "mmysite.net"
        end

        it 'creates sections' do
          expect(Section.count).to eq 0
          subject = Setup.new
          subject.install
          subject.install
          expect(Section.count).to eq 4
          section = Section.all
          expect(section[0].name).to eq "news"
          expect(section[0].slug).to eq "news"
          expect(section[0].site.slug).to eq "mysite"
          expect(section[0].section_type).to eq "content"
          expect(section[1].name).to eq "Biography"
          expect(section[1].slug).to eq "biography"
          expect(section[1].site.slug).to eq "mysite"
          expect(section[1].section_type).to eq "content"
          expect(section[2].name).to eq "Agenda"
          expect(section[2].slug).to eq "agenda"
          expect(section[2].site.slug).to eq "mysite"
          expect(section[2].section_type).to eq "content"
        end
      end

      context 'when the file is not valid' do
        it 'shows error'
      end
    end
  end
end
