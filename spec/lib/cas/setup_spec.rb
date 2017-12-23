require 'rails_helper'

module Cas
  RSpec.describe Setup do
    describe '#install' do
      let!(:superadmin) { create(:user, email: 'superadmin@example.com') }
      let!(:superadmin2) { create(:user, login: 'superadmin-login') }
      let!(:user) { create(:user, email: 'user@example.com') }

      before do
        expect(Section.count).to eq 0
      end

      subject { Setup.new }

      context 'when the file is valid' do
        it 'creates sites' do
          subject.install
          subject.install
          expect(Site.count).to eq 1
          site = Site.first
          expect(site.slug).to eq "mysite"
          expect(site.domains).to eq ["mysite.net"]
          expect(site.name).to eq "mysite.net"
        end

        it 'creates sections' do
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

        it 'adds all sites to all superadmins' do
          expect(superadmin.sites).to be_blank
          expect(superadmin2.sites).to be_blank
          expect(user.sites).to be_blank
          subject.install
          expect(superadmin.reload.sites).to match_array(::Cas::Site.all)
          expect(superadmin2.reload.sites).to match_array(::Cas::Site.all)
          expect(user.reload.sites).to be_blank
        end
      end

      context 'when the file is not valid' do
        it 'shows error'
      end
    end
  end
end
