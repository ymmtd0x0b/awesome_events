require 'rails_helper'

RSpec.describe Event, type: :model do
  before do
    user = User.create(
      provider:  'github',
      uid:       '12345',
      name:      'tester',
      image_url: 'https://example.com/12345.jpg',
    )

    @event = Event.new(
      name:     'Every Rails 輪読会',
      place:    'discord',
      content:  'RSpecを学習します。',
      start_at: '2000-11-11 09:00'.in_time_zone,
      end_at:   '2000-11-11 10:00'.in_time_zone,
      owner:    user,
    )
  end

  it '名前, 場所, 内容, 開始時間, 終了時間があれば有効であること' do
    expect(@event).to be_valid
  end

  it '名前が空白ならば無効であること' do
    @event.name = nil
    expect(@event).to be_invalid
  end

  it '場所が空白ならば無効であること' do
    @event.place = nil
    expect(@event).to be_invalid
  end

  it '内容が空白ならば無効であること' do
    @event.content = nil
    expect(@event).to be_invalid
  end

  it '開始時間が空白ならば無効であること' do
    @event.start_at = nil
    expect(@event).to be_invalid
  end

  it '終了時間が空白ならば無効であること' do
    @event.end_at = nil
    expect(@event).to be_invalid
  end

  it '名前は50文字以下なら有効であること' do
    @event.name = 'a' * 50
    expect(@event).to be_valid
  end

  it '名前は50文字より多いなら無効であること' do
    @event.name = 'a' * 51
    expect(@event).to be_invalid
  end

  it '場所は100文字以下なら有効であること' do
    @event.place = 'a' * 100
    expect(@event).to be_valid
  end

  it '場所は100文字より多いなら無効であること' do
    @event.place = 'a' * 101
    expect(@event).to be_invalid
  end

  it '内容は2000文字以内なら有効であること' do
    @event.content = 'a' * 2000
    expect(@event).to be_valid
  end

  it '内容は2000文字より多いなら無効であること' do
    @event.content = 'a' * 2001
    expect(@event).to be_invalid
  end

  it '開始時刻が終了時刻より前なら有効であることであること' do
    @event.start_at = '2000-11-11 09:00'.in_time_zone
    @event.end_at   = '2000-11-11 10:00'.in_time_zone
    expect(@event).to be_valid
  end

  it '開始時刻が終了時刻より後なら無効であること' do
    @event.start_at = '2000-11-11 10:00'.in_time_zone
    @event.end_at   = '2000-11-11 09:00'.in_time_zone
    expect(@event).to be_invalid
  end

  it '.png 画像なら有効であること' do
    @event.image = fixture_file_upload('files/image/sample.png')
    expect(@event).to be_valid
  end

  it '.jpg 画像なら有効であること' do
    @event.image = fixture_file_upload('files/image/sample.jpg')
    expect(@event).to be_valid
  end

  it '.jpeg 画像なら有効であること' do
    @event.image = fixture_file_upload('files/image/sample.jpeg')
    expect(@event).to be_valid
  end

  it '.png, .jpg, or .jpeg 以外の画像なら無効であることであること' do
    @event.image = fixture_file_upload('files/image/sample.gif')
    expect(@event).to be_invalid
  end

  it '10MB以下の画像なら有効であること' do
    @event.image = fixture_file_upload('files/image/sample_10MB.png')
    expect(@event).to be_valid
  end

  it '10MBより大きい画像なら無効であること' do
    @event.image = fixture_file_upload('files/image/sample_10.1MB.png')
    expect(@event).to be_invalid
  end

  it '横幅 2000px 以下の画像なら有効であること' do
    @event.image = fixture_file_upload('files/image/sample_2000*2000.png')
    expect(@event).to be_valid
  end

  it '横幅 2000px より大きい画像なら無効であること' do
    @event.image = fixture_file_upload('files/image/sample_2001*2000.png')
    expect(@event).to be_invalid
  end

  it '縦幅 2000px 以下の画像なら有効であること' do
    @event.image = fixture_file_upload('files/image/sample_2000*2000.png')
    expect(@event).to be_valid
  end

  it '縦幅 2000px より大きい画像なら無効であること' do
    @event.image = fixture_file_upload('files/image/sample_2000*2001.png')
    expect(@event).to be_invalid
  end

  describe '.created_by?' do
    before do
      @alice = User.create(
        provider:  'github',
        uid:       '11111',
        name:      'alice',
        image_url: 'https://example.com/12345.jpg',
      )
    end

    it 'ユーザーが主催者であるなら true を返すこと' do
      event = Event.create(
        name:     'Every Rails 輪読会',
        place:    'discord',
        content:  'RSpecを学習します。',
        start_at: '2000-11-11 09:00'.in_time_zone,
        end_at:   '2000-11-11 10:00'.in_time_zone,
        owner:    @alice,
      )
      expect(event.created_by?(@alice)).to eq true
    end

    it 'ユーザーが主催者でないなら false を返すこと' do
      bob = User.create(
        provider:  'github',
        uid:       '22222',
        name:      'bob',
        image_url: 'https://example.com/22222.jpg',
      )

      event = Event.create(
        name:     'Every Rails 輪読会',
        place:    'discord',
        content:  'RSpecを学習します。',
        start_at: '2000-11-11 09:00'.in_time_zone,
        end_at:   '2000-11-11 10:00'.in_time_zone,
        owner:    bob,
      )
      expect(event.created_by?(@alice)).to eq false
    end
  end
end
