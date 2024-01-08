FactoryBot.define do
  factory :ticket do
    association :event
    association :user
  end
end
