FactoryGirl.define do
  factory :site, class: ::Cas::Site do
    sequence(:name) { |n| "mysite-#{n}" }
    domains ['example.com']

    trait :yml_name do
      name "mysite"
      slug "mysite"
    end
  end
end
