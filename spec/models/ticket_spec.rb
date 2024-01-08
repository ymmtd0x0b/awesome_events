require 'rails_helper'

RSpec.describe Ticket, type: :model do
  it 'コメントは空白でも有効であること' do
    ticket = FactoryBot.build(:ticket, comment: nil)
    expect(ticket).to be_valid
  end

  it 'コメントは30文字以下なら有効であること' do
    ticket = FactoryBot.build(:ticket, comment: 'a' * 30)
    expect(ticket).to be_valid
  end

  it 'コメントは30文字より多いなら無効であること' do
    ticket = FactoryBot.build(:ticket, comment: 'a' * 31)
    expect(ticket).to be_invalid
  end
end
