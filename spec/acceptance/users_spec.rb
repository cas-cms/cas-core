require "rails_helper"

RSpec.feature 'User' do
  let(:admin) { create(:user, :admin, sites: [site, site2]) }
  let!(:writer) { create(:user, :writer, sites: [site]) }
  let!(:site) { create(:site) }
  let!(:site2) { create(:site, name: 'site2', domains: ['site2.com']) }
  let!(:site3) { create(:site, name: 'site3', domains: ['site3.com']) }

  context 'As admin' do
    background do
      login(admin)
    end

    scenario 'I create a user' do
      visit new_site_user_path(site)

      fill_in 'user[name]', with: "asd234"
      fill_in 'user[email]', with: "asd234@asd.com"
      check "site-id-#{site2.id}"
      select 'Admin', from: :user_roles
      fill_in 'user[password]', with: "123456"
      fill_in 'user[password_confirmation]', with: "123456"

      expect do
        click_on 'save-form'
      end.to change(::Cas::User, :count).by(1)

      expect(admin.roles).to eq ["admin"]

      new_user = ::Cas::User.where.not(id: admin.id).first!
      expect(new_user.sites.map(&:name)).to match_array([site, site2].map(&:name))
    end

    scenario 'I edit an user' do
      click_on "list-people"
      click_on "edit-user-#{writer.id}"

      fill_in 'user[name]', with: "asd2345"
      fill_in 'user[email]', with: "asd2345@asd.com"
      check "site-id-#{site2.id}"
      select 'Admin', from: :user_roles
      expect(writer.password).to eq "123456"
      fill_in 'user[password]', with: "new passw"
      fill_in 'user[password_confirmation]', with: "new passw"

      click_on "save-form"
      expect(current_path).to eq site_users_path(site)
      writer.reload
      expect(writer.sites.map(&:name)).to match_array([site, site2].map(&:name))
      expect(writer.name).to eq "asd2345"
      expect(writer.email).to eq "asd2345@asd.com"
      expect(writer.roles).to eq ["admin"]
      expect(writer.valid_password?("new passw")).to eq true
    end

    scenario "I edit an user without touching their password" do
      click_on "list-people"
      click_on "edit-user-#{writer.id}"

      fill_in 'user[name]', with: "new name"
      fill_in 'user[email]', with: "asd2345@asd.com"
      check "site-id-#{site2.id}"
      select 'Admin', from: :user_roles

      click_on "save-form"
      expect(current_path).to eq site_users_path(site)
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

      fill_in 'user[name]', with: "asd2345"
      fill_in 'user[email]', with: "asd2345@asd.com"
      fill_in 'user[password]', with: "123456"
      fill_in 'user[password_confirmation]', with: "123456"

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
