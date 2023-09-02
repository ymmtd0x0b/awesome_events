require 'rails_helper'

RSpec.describe "Events", type: :request do
  before do
    @user = FactoryBot.create(:user)
    @event = FactoryBot.create(:event, owner: @user)
  end

  describe "GET /event/:id" do
    it '...' do
      get event_path @event
      expect(response).to have_http_status(200)
    end
  end
end
