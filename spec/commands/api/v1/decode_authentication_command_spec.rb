# frozen_string_literal: true

require 'rails_helper'

module Api
  module V1
    RSpec.describe DecodeAuthenticationCommand do
      include ActiveSupport::Testing::TimeHelpers

      context 'without token' do
        subject { described_class.call('') }

        it { expect(subject.success?).to_not be }
        it { expect(subject.errors.keys).to include(:token) }
        it { expect(subject.errors.values.flatten).to include('Token is missing') }
      end

      context 'with expired token' do
        let!(:user) { FactoryBot.create(:user, id: 1) }
        let(:expired_header) do
          {
            'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiMSIsImV4cCI6MTU0' \
                               'MTcxOTc3NX0.StM6D6Zrl9lWYOM5PPjwObEr4s7XJIS_MhEAVl-eKmc'
          }
        end

        subject { described_class.call(expired_header) }

        it { expect(subject.success?).to_not be }
        it { expect(subject.errors.keys).to include(:token) }
        it { expect(subject.errors.values.flatten).to include('Token is expired') }
      end

      context 'with invalid token' do
        before { travel_to Time.zone.local(2017, 1, 1) }
        after { travel_back }

        let(:invalid_header) do
          {
            'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiMSIsImV4cCI6MTU0' \
                               'MTcxOTc3NX0.StM6D6Zrl9lWYOM5PPjwObEr4s7XJIS_MhEAVl-eKmc'
          }
        end

        subject { described_class.call(invalid_header) }

        it { expect(subject.success?).to_not be }
        it { expect(subject.errors.keys).to include(:token) }
        it { expect(subject.errors.values.flatten).to include('Token is invalid') }
      end

      context 'with valid token' do
        before { travel_to Time.zone.local(2017, 1, 1) }
        after { travel_back }
        let!(:user) { FactoryBot.create(:user, id: 1) }

        let(:valid_header) do
          {
            'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE0ODMzMTUyMDF9.5UB02L5' \
                                       'nicWUv2FEdvPIesNbxBWUaAKSCQd1ZXyCLcY'
          }
        end

        subject { described_class.call(valid_header) }

        it { expect(subject.success?).to be }
        it { expect(subject.errors).to be_empty }
      end
    end
  end
end
