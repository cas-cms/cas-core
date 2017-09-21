FactoryGirl.define do
  factory :content, class: Cas::Content do
    association :author, factory: :user
    association :section
    sequence(:title) { |n| "Content #{n}" }
    summary 'summary content'
    text 'new text'
    published true

    trait :survey do
      metadata({
        "survey" => {
          "questions" => {
            "0" => {
              "text" => "question 1",
              "votes" => "1"
            },
            "1" => {
              "text" => "question 2",
              "votes" => "2"
            },
            "2" => {
              "text" => "question 3",
              "votes" => "3"
            },
            "3" => {
              "text" => "",
              "votes" => "0"
            }
          }
        }
      })
    end
  end
end
