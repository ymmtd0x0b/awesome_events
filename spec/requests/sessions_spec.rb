require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  let(:user) {
    instance_double('User',
      id:        '1',
      provider:  'github',
      uid:       '123',
      name:      'tester',
      image_url: 'https://image.com/12345'
    )
  }

  before do
    allow(User).to receive(:find_or_create_from_auth_hash!).and_return(user)
  end

  describe "#create" do
    context 'when authentication by OmniAuth is successful' do
      it "logging in" do
        get '/auth/:provider/callback'
        expect(response).to have_http_status(302)
      end
    end
  end
end
