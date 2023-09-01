require 'rails_helper'

RSpec.describe Ticket, type: :model do

  it 'is valid with a comment of blank' do
    ticket = FactoryBot.build(:ticket, comment: nil)
    expect(ticket).to be_valid
  end

  it { is_expected.to validate_length_of(:comment).is_at_most(30) }
end
