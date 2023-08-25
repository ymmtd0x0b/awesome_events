require 'rails_helper'

RSpec.describe Ticket, type: :model do
  before do
    @user = User.create(
      provider:  'github',
      uid:       '12345',
      name:      'alice',
      image_url: 'https://image.com/12345',
    )

    event_owner = User.create(
      provider:  'github',
      uid:       '54321',
      name:      'bob',
      image_url: 'https://image.com/54321',
    )
    @event = Event.new(
      name:     'Every Rails 輪読会',
      place:    'discord',
      content:  'RSpecを学習します。',
      start_at: Time.zone.now,
      end_at:   Time.zone.now + 1.hour,
      owner:    event_owner,
    )
  end

  it 'is valid with a comment of blank' do
    ticket = @user.tickets.new(
      comment: nil,
      event:   @event,
    )
    expect(ticket).to be_valid
  end

  it 'is valid with a comment of less then or equal 30 characters' do
    ticket = @user.tickets.new(
      comment: 'a' * 30,
      event:   @event,
    )
    expect(ticket).to be_valid
  end

  it 'is invalid with a comment of more then 30 characters' do
    ticket = @user.tickets.new(
      comment: 'a' * 31,
      event:   @event,
    )
    ticket.valid?
    expect(ticket.errors[:comment]).to include('は30文字以内で入力してください')
  end
end
