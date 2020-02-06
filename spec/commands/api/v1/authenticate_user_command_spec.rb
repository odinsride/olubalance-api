# frozen_string_literal: true

require 'rails_helper'

module Api
  module V1
    RSpec.describe AuthenticateUserCommand do
      include ActiveSupport::Testing::TimeHelpers

      let!(:user) { FactoryBot.create(:user, id: 1, email: 'static@rails.local') }

      context 'with right user and password' do
        before { travel_to Time.zone.local(2017, 1, 1, 0, 0, 1, 1) }
        after { travel_back }

        let(:expected_token) do
          'eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJlbWFpbCI6InN0YXRpY0ByYWlscy5sb2NhbCIs' \
          'ImV4cCI6MTQ4MzMxNTIwMX0.71zo6MFBMz5C3gGVXRseskkfr2LQG1SimHYMgOtWC2k'
        end

        subject { described_class.call(user.email, 'topsecret') }

        it { expect(subject.success?).to be }
        it { expect(subject.result).to eq expected_token }
      end

      context 'with right user and wrong password' do
        subject { described_class.call(user.email, 'hackerman123') }

        it { expect(subject.success?).to_not be }
        it { expect(subject.result).to_not be }
      end

      context 'with everything wrong' do
        subject { described_class.call('dhh@rails.local', 'hackerman123') }

        it { expect(subject.success?).to_not be }
        it { expect(subject.result).to_not be }
      end
    end
  end
end
