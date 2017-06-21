FactoryGirl.define do
  factory :section, class: Cas::Section do
    association :site
    name 'news'
    slug 'news'
    section_type 'content'
  end
end
