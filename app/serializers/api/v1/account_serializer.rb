# frozen_string_literal: true

module Api
  module V1
    class AccountSerializer < ApplicationSerializer
      attributes :name, :current_balance, :last_four, :created_at, :updated_at
      belongs_to :user
    end
  end
end
