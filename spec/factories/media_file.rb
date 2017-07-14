FactoryGirl.define do
  factory :file, class: Cas::MediaFile do
    association :author, factory: :user
    association :attachable, factory: :content
    description 'summary content'
    service 's3'
    mime_type 'image/jpeg'
    file_data "{\"id\":\"fc8ff0798fee2a486cf335de777f3a0d.jpg\",\"storage\":\"cache\",\"metadata\":{\"size\":\"360454\",\"filename\":\"1 Intro.jpg\",\"mime_type\":\"image/jpeg\"}}"

    trait :with_path do
      path "fc8ff0798fee2a486cf335de777f3a0d.jpg"
    end
  end
end
