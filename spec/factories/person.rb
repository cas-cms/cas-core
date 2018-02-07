FactoryGirl.define do
  factory :person, class: ::Cas::Person do
    name "John Wayne"
    sequence(:email) { |n| "wayne#{n}@wayneenterprises.co" }
    login "my_username"
    password "123456"
    roles ['admin']

    trait :admin do
      roles ['admin']
    end

    trait :editor do
      roles ['editor']
    end

    trait :writer do
      roles ['writer']
    end
  end
end
