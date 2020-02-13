# frozen_string_literal: true

module Api
  module V1
    class AccountSerializer < ApplicationSerializer
      attributes :name, 
                 :current_balance, 
                 :last_four, 
                 :created_at, 
                 :updated_at,
                 :d_account_name,
                 :d_account_card_title,
                 :d_last_four,
                 :d_current_balance,
                 :d_pending_balance,
                 :d_non_pending_balance,
                 :d_account_name_balance,
                 :d_updated_at
      belongs_to :user
    end
  end
end
