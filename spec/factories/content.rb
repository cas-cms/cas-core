FactoryGirl.define do
  factory :content, class: Cas::Content do
    association :author, factory: :user
    association :section
   	title 'new content'
   	summary 'summary content'
   	text 'new text'
  end
end
