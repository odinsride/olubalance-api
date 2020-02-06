# frozen_string_literal: true

shared_context 'logged in user' do
  let(:user) { FactoryBot.create(:user) }
  before { allow_any_instance_of(Api::V1::DecodeAuthenticationCommand).to receive(:result).and_return(user) }
end
