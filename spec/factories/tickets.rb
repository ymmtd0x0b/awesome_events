FactoryBot.define do
  factory :ticket do
    association :event
    association :user

    trait :with_finished_event do
      association :event, factory: [:event, :with_event_end_at_yesterday]
    end
  end
end
