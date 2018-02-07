module DeviseSupport
  def sign_in
    @person ||= FactoryGirl.create(:person)

    # We action the login request using the parameters before we begin.
    # The login requests will match these to the user we just created in the factory, and authenticate us.
    post person_session_path,
      params: {
        'person[email]' => @person.email,
        'person[password]' => @person.password
      }
    follow_redirect!
  end
end
