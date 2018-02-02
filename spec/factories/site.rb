FactoryGirl.define do
  factory :site, class: Cas::Site do
    sequence(:name) { |n| "mysite#{n if n > 1}" }
    sequence(:domains) { |n| ["example.com#{n if n > 1}"] }
  end
end
