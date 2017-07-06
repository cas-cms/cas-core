require "rails_helper"

RSpec.feature 'User' do
  let(:admin) { create(:user, :admin) }
  let!(:writer) { create(:user, :writer) }

  context 'As admin' do
    background do
      login(admin)
    end

    scenario 'I create a user' do
      visit new_user_path

      fill_in 'user[name]', with: "asd234"
      fill_in 'user[email]', with: "asd234@asd.com"
      select 'Admin', from: :user_roles
      fill_in 'user[password]', with: "123456"
      fill_in 'user[password_confirmation]', with: "123456"

      expect do
        click_on 'save-form'
      end.to change(::Cas::User, :count).by(1)
    end

    scenario 'I edit an user' do
      click_on "list-people"
      click_on "edit-user-#{writer.id}"

      fill_in 'user[name]', with: "asd2345"
      fill_in 'user[email]', with: "asd2345@asd.com"
      select 'Admin', from: :user_roles
      fill_in 'user[password]', with: "123456"
      fill_in 'user[password_confirmation]', with: "123456"

      click_on "save-form"
      writer.reload
      expect(writer.name).to eq "asd2345"
      expect(writer.email).to eq "asd2345@asd.com"
      expect(writer.roles).to eq ["admin"]
      expect(writer.password).to eq "123456"
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
  end
end
