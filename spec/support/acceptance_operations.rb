module AcceptanceOperations
  def login(person)
    visit new_person_session_path

    fill_in 'person_email', with: person.email
    fill_in 'person_password', with: '123456'

    click_on 'login'
  end
end
