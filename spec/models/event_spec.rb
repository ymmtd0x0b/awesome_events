require 'rails_helper'

RSpec.describe Event, type: :model do
  it '名前, 場所, 内容, 開始時間, 終了時間があれば有効であること' do
    event = Event.new(
      name:     'Every Rails 輪読会',
      place:    'discord',
      content:  'RSpecを学習します。',
      start_at: '2000-11-11 09:00'.in_time_zone,
      end_at:   '2000-11-11 10:00'.in_time_zone,
      owner:    FactoryBot.create(:user),
    )
    expect(event).to be_valid
  end

  it '有効なファクトリを持つこと' do
    event = FactoryBot.build(:event)
    expect(event).to be_valid
  end

  it '名前が空白ならば無効であること' do
    event = FactoryBot.build(:event, name: nil)
    expect(event).to be_invalid
  end

  it '場所が空白ならば無効であること' do
    event = FactoryBot.build(:event, place: nil)
    expect(event).to be_invalid
  end

  it '内容が空白ならば無効であること' do
    event = FactoryBot.build(:event, content: nil)
    expect(event).to be_invalid
  end

  it '開始時間が空白ならば無効であること' do
    event = FactoryBot.build(:event, start_at: nil)
    expect(event).to be_invalid
  end

  it '終了時間が空白ならば無効であること' do
    event = FactoryBot.build(:event, end_at: nil)
    expect(event).to be_invalid
  end

  it '名前は50文字以下なら有効であること' do
    event = FactoryBot.build(:event, name: 'a' * 50)
    expect(event).to be_valid
  end

  it '名前は50文字より多いなら無効であること' do
    event = FactoryBot.build(:event, name: 'a' * 51)
    expect(event).to be_invalid
  end

  it '場所は100文字以下なら有効であること' do
    event = FactoryBot.build(:event, place: 'a' * 100)
    expect(event).to be_valid
  end

  it '場所は100文字より多いなら無効であること' do
    event = FactoryBot.build(:event, place: 'a' * 101)
    expect(event).to be_invalid
  end

  it '内容は2000文字以内なら有効であること' do
    event = FactoryBot.build(:event, content: 'a' * 2000)
    expect(event).to be_valid
  end

  it '内容は2000文字より多いなら無効であること' do
    event = FactoryBot.build(:event, content: 'a' * 2001)
    expect(event).to be_invalid
  end

  it '開始時刻が終了時刻より前なら有効であることであること' do
    event = FactoryBot.build(:event,
      start_at: '2000-11-11 09:00'.in_time_zone,
      end_at:   '2000-11-11 09:01'.in_time_zone
    )
    expect(event).to be_valid
  end

  it '開始時刻が終了時刻より後なら無効であること' do
    event = FactoryBot.build(:event,
      start_at: '2000-11-11 09:01'.in_time_zone,
      end_at:   '2000-11-11 09:00'.in_time_zone
    )
    expect(event).to be_invalid
  end

  it '.png 画像なら有効であること' do
    event = FactoryBot.build(:event,
      image: fixture_file_upload('files/image/sample.png')
    )
    expect(event).to be_valid
  end

  it '.jpg 画像なら有効であること' do
    event = FactoryBot.build(:event,
      image: fixture_file_upload('files/image/sample.jpg')
    )
    expect(event).to be_valid
  end

  it '.jpeg 画像なら有効であること' do
    event = FactoryBot.build(:event,
      image: fixture_file_upload('files/image/sample.jpeg')
    )
    expect(event).to be_valid
  end

  it '.png, .jpg, or .jpeg 以外の画像なら無効であることであること' do
    event = FactoryBot.build(:event,
      image: fixture_file_upload('files/image/sample.gif')
    )
    expect(event).to be_invalid
  end

  it '10MB以下の画像なら有効であること' do
    event = FactoryBot.build(:event,
      image: fixture_file_upload('files/image/sample_10MB.png')
    )
    expect(event).to be_valid
  end

  it '10MBより大きい画像なら無効であること' do
    event = FactoryBot.build(:event,
      image: fixture_file_upload('files/image/sample_10.1MB.png')
    )
    expect(event).to be_invalid
  end

  it '横幅 2000px 以下の画像なら有効であること' do
    event = FactoryBot.create(:event,
      image: fixture_file_upload('files/image/sample_2000*2000.png')
    )
    expect(event).to be_valid
  end

  it '横幅 2000px より大きい画像なら無効であること' do
    event = FactoryBot.build(:event,
      image: fixture_file_upload('files/image/sample_2001*2000.png')
    )
    expect(event).to be_invalid
  end

  it '縦幅 2000px 以下の画像なら有効であること' do
    event = FactoryBot.build(:event,
      image: fixture_file_upload('files/image/sample_2000*2000.png')
    )
    expect(event).to be_valid
  end

  it '縦幅 2000px より大きい画像なら無効であること' do
    event = FactoryBot.build(:event,
      image: fixture_file_upload('files/image/sample_2000*2001.png')
    )
    expect(event).to be_invalid
  end

  describe '.created_by?' do
    it 'ユーザーが主催者であるなら true を返すこと' do
      user = FactoryBot.create(:user)
      event = FactoryBot.create(:event, owner: user)
      expect(event.created_by?(user)).to eq true
    end

    it 'ユーザーが主催者でないなら false を返すこと' do
      user = FactoryBot.create(:user, name: 'owner')
      event = FactoryBot.create(:event, owner: user)
      other_user = FactoryBot.create(:user, name: 'other')
      expect(event.created_by?(other_user)).to eq false
    end
  end
end
