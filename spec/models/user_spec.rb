require 'rails_helper'

RSpec.describe User, type: :model do
  describe '.find_or_create_from_auth_hash!' do
    context 'when find a user' do
      it "returns the user's record" do
        user = User.create(
          provider:  'github',
          uid:       '12345',
          name:      'alice',
          image_url: 'https://example.com/12345.jpg',
        )

        # 完璧なハッシュデータでは
        # ・ユーザーを発見できたのか
        # ・発見できないから新たに作成したのか
        # を判別できないため発見できない際はエラーになるように nil を設定した
        auth_hash = {
          provider: 'github',
          uid:      '12345',
          info: {
            nickname: nil,
            image:    nil,
          }
        }
        found_user = User.find_or_create_from_auth_hash!(auth_hash)
        expect(found_user).to eq user
      end
    end

    context 'when not find user' do
      before do
        @auth_hash = {
          provider: 'github',
          uid:      '12345',
          info: {
            nickname:  'alice',
            image: 'https://example.com/12345.jpg',
          }
        }
      end

      it 'create record with a provider, uid, nickname, image_url' do
        expect {
          User.find_or_create_from_auth_hash!(@auth_hash)
        }.to change(User, :count).by(1)
      end

      it 'raises an error to create record without a provider' do
        @auth_hash[:provider] = nil
        expect {
          User.find_or_create_from_auth_hash!(@auth_hash)
        }.to raise_error ActiveRecord::NotNullViolation
      end

      it 'raises an error to create record without a uid' do
        @auth_hash[:uid] = nil
        expect {
          User.find_or_create_from_auth_hash!(@auth_hash)
        }.to raise_error ActiveRecord::NotNullViolation
      end

      it 'raises an error to create record without a nickname' do
        @auth_hash[:info][:nickname] = nil
        expect {
          User.find_or_create_from_auth_hash!(@auth_hash)
        }.to raise_error ActiveRecord::NotNullViolation
      end

      it 'raises an error to create record without a image_url' do
        @auth_hash[:info][:image] = nil
        expect {
          User.find_or_create_from_auth_hash!(@auth_hash)
        }.to raise_error ActiveRecord::NotNullViolation
      end
    end
  end

  describe '#destroy' do
    before do
      @user = User.create(
        provider:  'github',
        uid:       '12345',
        name:      'alice',
        image_url: 'https://example.com/12345.jpg',
      )

      @other_user = User.create(
        provider:  'github',
        uid:       '54321',
        name:      'bob',
        image_url: 'https://example.com/54321.jpg',
      )
    end

    context 'when user does not has publishing events' do
      it 'is successes destory record' do
        travel_to Time.local(2000, 3, 1, 0, 0) do
          Event.create(
            name: 'Every Rails 輪読会',
            content: '終了イベント',
            place: 'discord',
            start_at: Time.now.prev_month,
            end_at:   Time.now.prev_month + 1.hour,
            owner: @user,
          )
          expect { @user.destroy }.to change(User, :count).by(-1)
        end
      end
    end

    context 'when user has publishing events' do
      it 'abort destroy record with returns an error message' do
        travel_to Time.local(2000, 3, 1, 0, 0) do
          Event.create(
            name: 'Every Rails 輪読会',
            content: '公開中の未終了イベント',
            place: 'discord',
            start_at: Time.now.next_month,
            end_at:   Time.now.next_month + 1.hour,
            owner: @user,
          )
          @user.destroy
          expect(@user.errors[:base]).to include('公開中の未終了イベントが存在します。')
        end
      end
    end

    context 'when user does not has participating events' do
      it 'is successes destory record' do
        travel_to Time.local(2000, 3, 1, 0, 0) do
          event = Event.create(
            name: 'Every Rails 輪読会',
            content: '終了イベント',
            place: 'discord',
            start_at: Time.now.prev_month,
            end_at:   Time.now.prev_month + 1.hour,
            owner: @other_user,
          )
          event.tickets.create(user: @user)
          expect { @user.destroy }.to change(User, :count).by(-1)
        end
      end
    end

    context 'when user has participating events' do
      it 'abort destroy record with returns an error message' do
        travel_to Time.local(2000, 3, 1, 0, 0) do
          event = Event.create(
            name: 'Every Rails 輪読会',
            content: '公開中の未終了イベント',
            place: 'discord',
            start_at: Time.now.next_month,
            end_at:   Time.now.next_month + 1.hour,
            owner: @other_user,
          )
          event.tickets.create(user: @user)
          @user.destroy
          expect(@user.errors[:base]).to include('未終了の参加イベントが存在します。')
        end
      end
    end
  end
end
