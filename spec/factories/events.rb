FactoryBot.define do
  factory :event do
    name     { 'Every Rails 輪読会' }
    content  { '公開中のイベント' }
    place    { 'discord' }
    start_at { Time.zone.now }
    end_at   { Time.zone.now + 1.hour }
    association :owner
  end
end
