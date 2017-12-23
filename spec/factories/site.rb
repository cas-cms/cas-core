FactoryGirl.define do
  factory :site, class: Cas::Site do
    name "mysite"
    slug 'mysite'
    domains ['example.com']
  end
end
