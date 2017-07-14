module DeviseSupport
  def sign_in
    @user ||= FactoryGirl.create(:user)

    # We action the login request using the parameters before we begin.
    # The login requests will match these to the user we just created in the factory, and authenticate us.
    post user_session_path,
      params: {
        'user[email]' => @user.email,
        'user[password]' => @user.password
      }
    follow_redirect!
  end
end
