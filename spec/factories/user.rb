FactoryGirl.define do
  factory :user, class: Cas::User do
    name "John Wayne"
    email "wayne@wayneenterprises.co"
    password "123456"
    roles ['admin']
  end
end
