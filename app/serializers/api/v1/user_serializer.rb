# frozen_string_literal: true

module Api
  module V1
    class UserSerializer < ApplicationSerializer
      attributes :email, :first_name, :last_name, :timezone, :full_name, :member_since
      has_many :accounts
    end
  end
end
