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
    event = Event.new(name: nil)
    event.valid?
    expect(event.errors[:name]).to include('を入力してください')
  end

  it '場所が空白ならば無効であること' do
    event = Event.new(place: nil)
    event.valid?
    expect(event.errors[:place]).to include('を入力してください')
  end

  it '内容が空白ならば無効であること' do
    event = Event.new(content: nil)
    event.valid?
    expect(event.errors[:content]).to include('を入力してください')
  end

  it '開始時間が空白ならば無効であること' do
    event = Event.new(start_at: nil)
    event.valid?
    expect(event.errors[:start_at]).to include('を入力してください')
  end

  it '終了時間が空白ならば無効であること' do
    event = Event.new(end_at: nil)
    event.valid?
    expect(event.errors[:end_at]).to include('を入力してください')
  end

  it '名前は50文字以下なら有効であること' do
    @event.name = 'a' * 50
    expect(@event).to be_valid
  end

  it '名前は50文字より多いなら無効であること' do
    event = Event.new(name: 'a' * 51)
    event.valid?
    expect(event.errors[:name]).to include('は50文字以内で入力してください')
  end

  it '場所は100文字以下なら有効であること' do
    @event.place = 'a' * 100
    expect(@event).to be_valid
  end

  it '場所は100文字より多いなら無効であること' do
    event = Event.new(place: 'a' * 101)
    event.valid?
    expect(event.errors[:place]).to include('は100文字以内で入力してください')
  end

  it '内容は2000文字以内なら有効であること' do
    @event.content = 'a' * 2000
    expect(@event).to be_valid
  end

  it '内容は2000文字より多いなら無効であること' do
    event = Event.new(content: 'a' * 2001)
    event.valid?
    expect(event.errors[:content]).to include('は2000文字以内で入力してください')
  end

  it '開始時刻が終了時刻より前なら有効であることであること' do
    @event.start_at = '2000-11-11 09:00'.in_time_zone
    @event.end_at   = '2000-11-11 10:00'.in_time_zone
    expect(@event).to be_valid
  end

  it '開始時刻が終了時刻より後なら無効であること' do
    event = Event.new(
      start_at: '2000-11-11 10:00'.in_time_zone,
      end_at:   '2000-11-11 09:00'.in_time_zone,
    )
    event.valid?
    expect(event.errors[:start_at]).to include('は終了時間よりも前に設定してください')
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
    event = Event.new(image: fixture_file_upload('files/image/sample.gif'))
    event.valid?
    expect(event.errors[:image]).to include('のContent Typeが不正です')
  end

  it '10MB以下の画像なら有効であること' do
    @event.image = fixture_file_upload('files/image/sample_10MB.png')
    expect(@event).to be_valid
  end

  it '10MBより大きい画像なら無効であること' do
    event = Event.new(image: fixture_file_upload('files/image/sample_10.1MB.png'))
    event.valid?
    expect(event.errors[:image]).to include('の容量 10.1MB が許容範囲外です')
  end

  it '横幅 2000px 以下の画像なら有効であること' do
    @event.image = fixture_file_upload('files/image/sample_2000*2000.png')
    expect(@event).to be_valid
  end

  it '横幅 2000px より大きい画像なら無効であること' do
    event = Event.new(image: fixture_file_upload('files/image/sample_2001*2000.png'))
    event.valid?
    expect(event.errors[:image]).to include('の横幅は 2000 ピクセル以下にしてください')
  end

  it '縦幅 2000px 以下の画像なら有効であること' do
    @event.image = fixture_file_upload('files/image/sample_2000*2000.png')
    expect(@event).to be_valid
  end

  it '縦幅 2000px より大きい画像なら無効であること' do
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
