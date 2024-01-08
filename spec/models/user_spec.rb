require 'rails_helper'

RSpec.describe User, type: :model do
  describe '.find_or_create_from_auth_hash!' do
    context 'データベースに該当するユーザーを見つけた場合' do
      it "そのユーザーレコードを返すこと" do
        user = FactoryBot.create(:user, provider: 'github', uid: '12345')

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
    let(:user) { FactoryBot.create(:user) }

    context 'イベントの主催者(オーナー)である場合' do
      before do
        FactoryBot.create(:event,
          start_at: '2000-08-01 00:30'.in_time_zone,
          end_at:   '2000-08-01 00:40'.in_time_zone,
          owner: user)
      end

      it '開催前なら、ユーザー削除できないこと' do
        travel_to '2000-08-01 00:29'.in_time_zone do
          expect(user.destroy).to eq false
        end
      end

      it '開催中なら、ユーザー削除できないこと' do
        travel_to '2000-08-01 00:30'.in_time_zone do
          expect(user.destroy).to eq false
        end

        travel_to '2000-08-01 00:39'.in_time_zone do
          expect(user.destroy).to eq false
        end
      end

      it '開催終了後なら、ユーザー削除できること' do
        travel_to '2000-08-01 00:40'.in_time_zone do
          expect { user.destroy }.to change(User, :count).by(-1)
        end
      end
    end

    context 'イベントの参加者である場合' do
      before do
        event = FactoryBot.create(:event,
                            start_at: '2000-08-01 00:30'.in_time_zone,
                            end_at:   '2000-08-01 00:40'.in_time_zone)
        FactoryBot.create(:ticket, user: user, event: event)
      end

      it '開催前なら、ユーザー削除できないこと' do
        travel_to '2000-08-01 00:29'.in_time_zone do
          expect(user.destroy).to eq false
        end
      end

      it '開催中なら、ユーザー削除できないこと' do
        travel_to '2000-08-01 00:30'.in_time_zone do
          expect(user.destroy).to eq false
        end

        travel_to '2000-08-01 00:39'.in_time_zone do
          expect(user.destroy).to eq false
        end
      end

      it '開催終了後なら、ユーザー削除できること' do
        travel_to '2000-08-01 00:40'.in_time_zone do
          expect{ user.destroy }.to change(User, :count).by(-1)
        end
      end
    end
  end
end
