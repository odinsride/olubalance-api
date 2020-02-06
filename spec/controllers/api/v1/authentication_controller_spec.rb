# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::AuthenticationController, type: :controller do
  describe 'POST #authenticate' do
    let(:password) { 'topsecret' }
    let(:user) { FactoryBot.create(:user) }
    let(:user_params) { { email: user.email, password: password } }

    it 'returns http success' do
      post :authenticate, params: user_params
      expect(response).to be_successful
      expect(response_json.keys).to eq %w[email jwt]
    end

    it 'returns unauthorized for invalid params' do
      post :authenticate, params: { email: user.email, password: 'incorrect' }
      expect(response).to have_http_status(401)
    end
  end
end
