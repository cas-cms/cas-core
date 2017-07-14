FactoryGirl.define do
  factory :content, class: Cas::Content do
    association :author, factory: :user
    association :section
    sequence(:title) { |n| "Content #{n}" }
    summary 'summary content'
    text 'new text'
  end
end
