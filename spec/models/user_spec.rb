require 'rails_helper'

RSpec.describe User, type: :model do
  describe '.find_or_create_from_auth_hash!' do
    context 'データベースに該当するユーザーを見つけた場合' do
      it "そのユーザーレコードを返すこと" do
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

    context 'データベースに該当するユーザーが見つからない場合' do
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

      it 'プロバイダ, UID, ニックネーム, 画像URL があればユーザーを作成すること' do
        expect {
          User.find_or_create_from_auth_hash!(@auth_hash)
        }.to change(User, :count).by(1)
      end

      it 'プロバイダ が無ければエラーを発生させること' do
        @auth_hash[:provider] = nil
        expect {
          User.find_or_create_from_auth_hash!(@auth_hash)
        }.to raise_error ActiveRecord::NotNullViolation
      end

      it 'UID が無ければエラーを発生させること' do
        @auth_hash[:uid] = nil
        expect {
          User.find_or_create_from_auth_hash!(@auth_hash)
        }.to raise_error ActiveRecord::NotNullViolation
      end

      it 'ニックネーム が無ければエラーを発生させること' do
        @auth_hash[:info][:nickname] = nil
        expect {
          User.find_or_create_from_auth_hash!(@auth_hash)
        }.to raise_error ActiveRecord::NotNullViolation
      end

      it '画像URL が無ければエラーを発生させること' do
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

    context '主催するイベントが終了している場合' do
      it 'ユーザーの削除に成功すること' do
        travel_to '2000-08-01 00:00'.in_time_zone do
          Event.create(
            name: 'Every Rails 輪読会',
            content: '終了したイベント',
            place: 'discord',
            start_at: '2000-07-31 23:00'.in_time_zone,
            end_at:   '2000-07-31 23:59'.in_time_zone,
            owner: @user,
          )
          expect { @user.destroy }.to change(User, :count).by(-1)
        end
      end
    end

    context '主催するイベントが終了していない場合' do
      it 'ユーザーの削除に失敗すること' do
        travel_to '2000-08-01 00:00'.in_time_zone do
          Event.create(
            name: 'Every Rails 輪読会',
            content: '公開中の未終了イベント',
            place: 'discord',
            start_at: '2000-08-01 00:00'.in_time_zone,
            end_at:   '2000-08-01 01:00'.in_time_zone,
            owner: @user,
          )
          expect(@user.destroy).to eq false
        end
      end
    end

    context '参加表明したイベントが終了している場合' do
      it 'ユーザーの削除に成功すること' do
        travel_to '2000-08-01 00:00'.in_time_zone do
          event = Event.create(
            name: 'Every Rails 輪読会',
            content: '終了したイベント',
            place: 'discord',
            start_at: '2000-07-31 23:00'.in_time_zone,
            end_at:   '2000-07-31 23:59'.in_time_zone,
            owner: @other_user,
          )
          event.tickets.create(user: @user)
          expect { @user.destroy }.to change(User, :count).by(-1)
        end
      end
    end

    context '参加表明したイベントが終了していない場合' do
      it 'ユーザーの削除に失敗すること' do
        travel_to '2000-08-01 00:00'.in_time_zone do
          event = Event.create(
            name: 'Every Rails 輪読会',
            content: '公開中の未終了イベント',
            place: 'discord',
            start_at: '2000-08-01 00:00'.in_time_zone,
            end_at:   '2000-08-01 01:00'.in_time_zone,
            owner: @other_user,
          )
          event.tickets.create(user: @user)
          expect(@user.destroy).to eq false
        end
      end
    end
  end
end
