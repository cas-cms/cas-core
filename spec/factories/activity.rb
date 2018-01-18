FactoryGirl.define do
  factory :activity, class: Cas::Activity do
    association :user
    association :site
    association :subject, factory: :content
    event_name 'create'
  end
end
