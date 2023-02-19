require 'rails_helper'

module Cas
  RSpec.describe Installation do
    describe '#generate_sites' do
      let!(:superadmin) { create(:user, login: 'superadmin-login') }
      let!(:user) { create(:user, email: 'user@example.com') }
      let(:new_admin) { Cas::User.find_by(email: 'admin@example.com') }

      before do
        expect(Section.count).to eq 0
      end

      subject { described_class.new(filename: "lib/generators/cas/templates/cas.config.yml") }

      context 'when the file is valid' do
        it 'creates sites' do
          # Runs twice to make sure things aren't deleted
          subject.generate_sites
          subject.generate_sites
          expect(Site.count).to eq 1
          site = Site.first
          expect(site.slug).to eq "mysite"
          expect(site.domains).to eq ["mysite.net"]
          expect(site.name).to eq "mysite.net"
        end

        it 'creates sections' do
          # Runs twice to make sure things aren't deleted
          subject.generate_sites
          subject.generate_sites
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

        it "creates admins" do
          # Runs twice to make sure things aren't deleted
          expect {
            subject.generate_sites
            subject.generate_sites
          }.to change(::Cas::User, :count).from(2).to(3)

          expect(
            new_admin
          ).to be_present
        end

        it 'adds all sites to all superadmins' do
          expect(superadmin.sites).to be_blank
          expect(user.sites).to be_blank
          subject.generate_sites

          expect(superadmin.reload.sites).to match_array(::Cas::Site.all)
          expect(user.reload.sites).to be_blank
          expect(new_admin.sites).to match_array(::Cas::Site.all)
        end
      end

      context 'when the file is not valid' do
        it 'shows error'
      end
    end
  end
end
