module AcceptanceOperations
  def login(user)
    visit new_user_session_path

    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: '123456'

    click_on 'login'
  end
end
