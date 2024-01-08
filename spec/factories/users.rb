FactoryBot.define do
  factory :user, aliases: [:owner] do
    provider       { 'github' }
    sequence(:uid) { |n| n.to_s }
    name           { 'tester' }
    image_url      { 'https://example.com/12345.jpg' }
  end
end
