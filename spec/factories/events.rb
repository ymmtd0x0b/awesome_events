FactoryBot.define do
  factory :event do
    name     { 'Every Rails 輪読会' }
    content  { '公開中のイベント' }
    place    { 'discord' }
    start_at { Time.zone.now }
    end_at   { Time.zone.now + 1.hour }
    association :owner

    trait :with_event_end_at_yesterday do
      content  { '終了したイベント' }
      start_at { Time.zone.now.yesterday }
      end_at   { Time.zone.now.yesterday + 1.hour }
    end
  end
end
