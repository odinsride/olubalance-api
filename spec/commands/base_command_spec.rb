# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BaseCommand do
  context 'error handling' do
    it 'raises a NotImplementedError on initialize' do
      expect do
        described_class.new
      end.to raise_error(NotImplementedError)
    end

    it 'raises a NotImplementedError on call' do
      expect do
        described_class.call
      end.to raise_error(NotImplementedError)
    end
  end
end
