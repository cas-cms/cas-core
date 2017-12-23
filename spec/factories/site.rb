FactoryGirl.define do
  factory :site, class: Cas::Site do
    name "mysite"
    domains ['example.com']
  end
end
