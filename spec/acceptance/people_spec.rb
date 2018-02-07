require "rails_helper"

RSpec.feature 'Person' do
  let(:admin) { create(:person, :admin, sites: [site, site2]) }
  let!(:writer) { create(:person, :writer, sites: [site]) }
  let!(:site) { create(:site) }
  let!(:site2) { create(:site, name: 'site2', domains: ['site2.com']) }
  let!(:site3) { create(:site, name: 'site3', domains: ['site3.com']) }

  context 'As admin' do
    background do
      login(admin)
    end

    scenario 'I create a person' do
      visit new_site_person_path(site)

      fill_in 'person[name]', with: "asd234"
      fill_in 'person[email]', with: "asd234@asd.com"
      check "site-id-#{site2.id}"
      select 'Admin', from: :person_roles
      fill_in 'person[password]', with: "123456"
      fill_in 'person[password_confirmation]', with: "123456"

      expect do
        click_on 'save-form'
      end.to change(::Cas::Person, :count).by(1)

      expect(admin.roles).to eq ["admin"]

      new_person = ::Cas::Person.where(name: "asd234").first!
      expect(new_person.sites.map(&:name)).to match_array([site, site2].map(&:name))
    end

    scenario 'I edit an person' do
      click_on "list-people"
      click_on "edit-person-#{writer.id}"

      fill_in 'person[name]', with: "asd2345"
      fill_in 'person[email]', with: "asd2345@asd.com"
      check "site-id-#{site2.id}"
      select 'Admin', from: :person_roles
      expect(writer.password).to eq "123456"
      fill_in 'person[password]', with: "new passw"
      fill_in 'person[password_confirmation]', with: "new passw"

      click_on "save-form"
      expect(current_path).to eq site_people_path(site)
      writer.reload
      expect(writer.sites.map(&:name)).to match_array([site, site2].map(&:name))
      expect(writer.name).to eq "asd2345"
      expect(writer.email).to eq "asd2345@asd.com"
      expect(writer.roles).to eq ["admin"]
      expect(writer.valid_password?("new passw")).to eq true
    end

    scenario "I edit an person without touching their password" do
      click_on "list-people"
      click_on "edit-person-#{writer.id}"

      fill_in 'person[name]', with: "new name"
      fill_in 'person[email]', with: "asd2345@asd.com"
      check "site-id-#{site2.id}"
      select 'Admin', from: :person_roles

      click_on "save-form"
      expect(current_path).to eq site_people_path(site)
      writer.reload
      expect(writer.sites.map(&:name)).to match_array([site, site2].map(&:name))
      expect(writer.name).to eq "new name"
      expect(writer.email).to eq "asd2345@asd.com"
      expect(writer.roles).to eq ["admin"]
      expect(writer.valid_password?("123456")).to eq true
    end
  end

  context 'As writer' do
    background do
      login(writer)
    end

    scenario 'I edit my profile' do
      click_on "edit-profile"

      fill_in 'person[name]', with: "asd2345"
      fill_in 'person[email]', with: "asd2345@asd.com"
      fill_in 'person[password]', with: "123456"
      fill_in 'person[password_confirmation]', with: "123456"

      click_on "save-form"
      writer.reload
      expect(writer.name).to eq "asd2345"
      expect(writer.email).to eq "asd2345@asd.com"
      expect(writer.password).to eq "123456"
    end

    scenario 'I cannot see other people list' do
      expect(page).to_not have_selector "#list-people"
    end
  end
end
