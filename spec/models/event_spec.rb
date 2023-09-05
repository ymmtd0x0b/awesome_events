require 'rails_helper'

RSpec.describe Event, type: :model do
  it 'is valid with a name, place, content, start_at, end_at' do
    event = Event.new(
      name:     'Every Rails 輪読会',
      place:    'discord',
      content:  'RSpecを学習します。',
      start_at: Time.zone.now,
      end_at:   Time.zone.now + 1.hour,
      owner:    FactoryBot.create(:user),
    )
    expect(event).to be_valid
  end

  it 'has a valid factory' do
    event = FactoryBot.build(:event)
    expect(event).to be_valid
  end

  it 'is invalid without a name' do
    event = FactoryBot.build(:event, name: nil)
    event.valid?
    expect(event.errors[:name]).to include('を入力してください')
  end

  it 'is invalid without a place' do
    event = FactoryBot.build(:event, place: nil)
    event.valid?
    expect(event.errors[:place]).to include('を入力してください')
  end

  it 'is invalid without a content' do
    event = FactoryBot.build(:event, content: nil)
    event.valid?
    expect(event.errors[:content]).to include('を入力してください')
  end

  it 'is invalid without a start_at' do
    event = FactoryBot.build(:event, start_at: nil)
    event.valid?
    expect(event.errors[:start_at]).to include('を入力してください')
  end

  it 'is invalid without a end_at' do
    event = FactoryBot.build(:event, end_at: nil)
    event.valid?
    expect(event.errors[:end_at]).to include('を入力してください')
  end

  it { is_expected.to validate_length_of(:name).is_at_most(50) }
  it { is_expected.to validate_length_of(:place).is_at_most(100) }
  it { is_expected.to validate_length_of(:content).is_at_most(2000) }

  it 'is valid with start at should be before end at' do
    event = FactoryBot.build(:event,
      start_at: Time.zone.now,
      end_at:   Time.zone.now + 1.hour
    )
    expect(event).to be_valid
  end

  it 'is invalid with start at should be after end at' do
    event = FactoryBot.build(:event,
      start_at: Time.zone.now,
      end_at:   Time.zone.now - 1.hour,
    )
    event.valid?
    expect(event.errors[:start_at]).to include('は終了時間よりも前に設定してください')
  end

  it 'is valid with a .png image' do
    event = FactoryBot.build(:event,
      image: fixture_file_upload('files/image/sample.png')
    )
    expect(event).to be_valid
  end

  it 'is valid with a .jpg image' do
    event = FactoryBot.build(:event,
      image: fixture_file_upload('files/image/sample.jpg')
    )
    expect(event).to be_valid
  end

  it 'is valid with a .jpeg image' do
    event = FactoryBot.build(:event,
      image: fixture_file_upload('files/image/sample.jpeg')
    )
    expect(event).to be_valid
  end

  it 'is invalid except on a .png, .jpg, or .jpeg image' do
    event = FactoryBot.build(:event,
      image: fixture_file_upload('files/image/sample.gif')
    )
    event.valid?
    expect(event.errors[:image]).to include('のContent Typeが不正です')
  end

  it 'is valid with a image of less than or equal to 10MB' do
    event = FactoryBot.build(:event,
      image: fixture_file_upload('files/image/sample_10MB.png')
    )
    expect(event).to be_valid
  end

  it 'is invalid with a image greater than 10MB' do
    event = FactoryBot.build(:event,
      image: fixture_file_upload('files/image/sample_10.1MB.png')
    )
    event.valid?
    expect(event.errors[:image]).to include('の容量 10.1MB が許容範囲外です')
  end

  it 'is valid with a image of less than 2000px wide' do
    event = FactoryBot.create(:event,
      image: fixture_file_upload('files/image/sample_2000*2000.png')
    )
    expect(event).to be_valid
  end

  it 'is invalid with a image of more than 2000px wide' do
    event = FactoryBot.build(:event,
      image: fixture_file_upload('files/image/sample_2001*2000.png')
    )
    event.valid?
    expect(event.errors[:image]).to include('の横幅は 2000 ピクセル以下にしてください')
  end

  it 'is valid with a image of less than 2000px height' do
    event = FactoryBot.build(:event,
      image: fixture_file_upload('files/image/sample_2000*2000.png')
    )
    expect(event).to be_valid
  end

  it 'is invalid with a image of more than 2000px height' do
    event = FactoryBot.build(:event,
      image: fixture_file_upload('files/image/sample_2000*2001.png')
    )
    event.valid?
    expect(event.errors[:image]).to include('の縦幅は 2000 ピクセル以下にしてください')
  end

  describe '.created_by?' do
    it 'returns true with user and this event owner the same' do
      user = FactoryBot.create(:user)
      event = FactoryBot.create(:event, owner: user)
      expect(event.created_by?(user)).to eq true
    end

    it 'returns false with user and this event owner the not same' do
      event = FactoryBot.create(:event)
      other_user = FactoryBot.create(:user)
      expect(event.created_by?(other_user)).to eq false
    end
  end
end
