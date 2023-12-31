FactoryBot.define do
  factory :user, aliases: [:owner] do
    provider       { 'github' }
    sequence(:uid) { |n| n.to_s }
    name           { 'tester' }
    image_url      { 'https://example.com/12345.jpg' }

    trait :with_publishing_event do
      after(:create) { |user| FactoryBot.create(:event, owner: user) }
    end

    trait :with_finished_event do
      after(:create) { |user| FactoryBot.create(:event, :with_event_end_at_yesterday, owner: user) }
    end

    trait :with_participating_event do
      after(:create) { |user| FactoryBot.create(:ticket, user: user) }
    end

    trait :with_participating_event_that_has_finished do
      after(:create) { |user| FactoryBot.create(:ticket, :with_finished_event, user: user) }
    end
  end
end
