FactoryGirl.define do
  factory :category, class: Cas::Category do
    association :section
    name "Sports"
  end
end
