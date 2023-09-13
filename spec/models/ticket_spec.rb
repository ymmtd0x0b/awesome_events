require 'rails_helper'

RSpec.describe Ticket, type: :model do
  before do
    @user = User.create(
      provider:  'github',
      uid:       '12345',
      name:      'alice',
      image_url: 'https://example.com/12345.jpg',
    )

    event_owner = User.create(
      provider:  'github',
      uid:       '54321',
      name:      'bob',
      image_url: 'https://example.com/54321.jpg',
    )
    @event = Event.new(
      name:     'Every Rails 輪読会',
      place:    'discord',
      content:  'RSpecを学習します。',
      start_at: '2000-11-11 09:00'.in_time_zone,
      end_at:   '2000-11-11 10:00'.in_time_zone,
      owner:    event_owner,
    )
  end

  it 'コメントは空白でも有効であること' do
    ticket = @user.tickets.new(
      comment: nil,
      event:   @event,
    )
    expect(ticket).to be_valid
  end

  it 'コメントは30文字以下なら有効であること' do
    ticket = @user.tickets.new(
      comment: 'a' * 30,
      event:   @event,
    )
    expect(ticket).to be_valid
  end

  it 'コメントは30文字より多いなら無効であること' do
    ticket = @user.tickets.new(
      comment: 'a' * 31,
      event:   @event,
    )
    expect(ticket).to be_invalid
  end
end
