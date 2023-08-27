require 'rails_helper'

RSpec.describe Ticket, type: :model do

  it 'is valid with a comment of blank' do
    ticket = FactoryBot.build(:ticket, comment: nil)
    expect(ticket).to be_valid
  end

  it 'is valid with a comment of less then or equal 30 characters' do
    ticket = FactoryBot.build(:ticket, comment: 'a' * 30)
    expect(ticket).to be_valid
  end

  it 'is invalid with a comment of more then 30 characters' do
    ticket = FactoryBot.build(:ticket, comment: 'a' * 31)
    ticket.valid?
    expect(ticket.errors[:comment]).to include('は30文字以内で入力してください')
  end
end
