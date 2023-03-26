FactoryGirl.define do
  factory :section, class: Cas::Section do
    association :site
    name 'news'
    slug 'news'
    section_type 'content'

    trait :news do
      name 'news'
      slug 'news'
      section_type 'content'
    end

    trait :agenda do
      name 'Agenda'
      slug 'agenda'
      section_type 'content'
    end

    trait :survey do
      name 'Survey'
      slug 'survey'
      section_type 'survey'
    end

    trait :biography do
      name 'Biography'
      slug 'biography'
      section_type 'content'
    end
  end
end
