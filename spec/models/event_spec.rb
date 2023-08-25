require 'rails_helper'

RSpec.describe Event, type: :model do
  before do
    user = User.create(
      provider:  'github',
      uid:       '12345',
      name:      'tester',
      image_url: 'https://image.com/12345',
    )

    @event = Event.new(
      name:     'Every Rails 輪読会',
      place:    'discord',
      content:  'RSpecを学習します。',
      start_at: Time.zone.now,
      end_at:   Time.zone.now + 1.hour,
      owner:    user,
    )
  end

  it 'is valid with a name, place, content, start_at, end_at' do
    expect(@event).to be_valid
  end

  it 'is invalid without a name' do
    event = Event.new(name: nil)
    event.valid?
    expect(event.errors[:name]).to include('を入力してください')
  end

  it 'is invalid without a place' do
    event = Event.new(place: nil)
    event.valid?
    expect(event.errors[:place]).to include('を入力してください')
  end

  it 'is invalid without a content' do
    event = Event.new(content: nil)
    event.valid?
    expect(event.errors[:content]).to include('を入力してください')
  end

  it 'is invalid without a start_at' do
    event = Event.new(start_at: nil)
    event.valid?
    expect(event.errors[:start_at]).to include('を入力してください')
  end

  it 'is invalid without a end_at' do
    event = Event.new(end_at: nil)
    event.valid?
    expect(event.errors[:end_at]).to include('を入力してください')
  end

  it 'is valid with a name less than 50 characters' do
    @event.name = 'a' * 50
    expect(@event).to be_valid
  end

  it 'is invalid with a name of more than 50 characters' do
    event = Event.new(name: 'a' * 51)
    event.valid?
    expect(event.errors[:name]).to include('は50文字以内で入力してください')
  end

  it 'is valid with a place less than 100 characters' do
    @event.place = 'a' * 100
    expect(@event).to be_valid
  end

  it 'is invalid with a place of more than 100 characters' do
    event = Event.new(place: 'a' * 101)
    event.valid?
    expect(event.errors[:place]).to include('は100文字以内で入力してください')
  end

  it 'is valid with a content less than 2000 characters' do
    @event.content = 'a' * 2000
    expect(@event).to be_valid
  end

  it 'is invalid with a content of more than 2000 characters' do
    event = Event.new(content: 'a' * 2001)
    event.valid?
    expect(event.errors[:content]).to include('は2000文字以内で入力してください')
  end

  it 'is valid with start at should be before end at' do
    @event.start_at = Time.zone.now
    @event.end_at   = Time.zone.now + 1.hour
    expect(@event).to be_valid
  end

  it 'is invalid with start at should be after end at' do
    event = Event.new(
      start_at: Time.zone.now,
      end_at:   Time.zone.now - 1.hour,
    )
    event.valid?
    expect(event.errors[:start_at]).to include('は終了時間よりも前に設定してください')
  end

  it 'is valid with a .png image' do
    @event.image = fixture_file_upload('files/image/sample.png')
    expect(@event).to be_valid
  end

  it 'is valid with a .jpg image' do
    @event.image = fixture_file_upload('files/image/sample.jpg')
    expect(@event).to be_valid
  end

  it 'is valid with a .jpeg image' do
    @event.image = fixture_file_upload('files/image/sample.jpeg')
    expect(@event).to be_valid
  end

  it 'is invalid except on a .png, .jpg, or .jpeg image' do
    event = Event.new(image: fixture_file_upload('files/image/sample.gif'))
    event.valid?
    expect(event.errors[:image]).to include('のContent Typeが不正です')
  end

  it 'is valid with a image of less than or equal to 10MB' do
    @event.image = fixture_file_upload('files/image/sample_10MB.png')
    expect(@event).to be_valid
  end

  it 'is invalid with a image greater than 10MB' do
    event = Event.new(image: fixture_file_upload('files/image/sample_10.1MB.png'))
    event.valid?
    expect(event.errors[:image]).to include('の容量 10.1MB が許容範囲外です')
  end

  it 'is valid with a image of less than 2000px wide' do
    @event.image = fixture_file_upload('files/image/sample_2000*2000.png')
    expect(@event).to be_valid
  end

  it 'is invalid with a image of more than 2000px wide' do
    event = Event.new(image: fixture_file_upload('files/image/sample_2001*2000.png'))
    event.valid?
    expect(event.errors[:image]).to include('の横幅は 2000 ピクセル以下にしてください')
  end

  it 'is valid with a image of less than 2000px height' do
    @event.image = fixture_file_upload('files/image/sample_2000*2000.png')
    expect(@event).to be_valid
  end

  it 'is invalid with a image of more than 2000px height' do
    event = Event.new(image: fixture_file_upload('files/image/sample_2000*2001.png'))
    event.valid?
    expect(event.errors[:image]).to include('の縦幅は 2000 ピクセル以下にしてください')
  end

  describe '.created_by?' do
    before do
      @alice = User.create(
        provider:  'github',
        uid:       '11111',
        name:      'alice',
        image_url: 'https://image.com/12345',
      )
    end

    it 'returns true with user and this event owner the same' do
      event = Event.create(
        name:     'Every Rails 輪読会',
        place:    'discord',
        content:  'RSpecを学習します。',
        start_at: Time.zone.now,
        end_at:   Time.zone.now + 1.hour,
        owner:    @alice,
      )
      expect(event.created_by?(@alice)).to eq true
    end

    it 'returns false with user and this event owner the not same' do
      bob = User.create(
        provider:  'github',
        uid:       '22222',
        name:      'bob',
        image_url: 'https://image.com/22222',
      )

      event = Event.create(
        name:     'Every Rails 輪読会',
        place:    'discord',
        content:  'RSpecを学習します。',
        start_at: Time.zone.now,
        end_at:   Time.zone.now + 1.hour,
        owner:    bob,
      )
      expect(event.created_by?(@alice)).to eq false
    end
  end
end
