# frozen_string_literal: true

module Api
  module V1
    class AccountsController < ApiController
      before_action :set_account, only: %i[show edit update destroy activate deactivate]

      # GET /accounts
      # GET /accounts.json
      def index
        @accounts = current_user.accounts.where(active: true).order('created_at ASC')
        @accounts = AccountSerializer.new(@accounts).serialized_json
        render json: @accounts
      end

      def inactive
        @inactiveaccounts = current_user.accounts.where(active: false).order('created_at ASC')
        @inactiveaccounts = AccountSerializer.new(@inactiveaccounts).serialized_json
        render json: @inactiveaccounts
      end

      # GET /accounts/1
      # GET /accounts/1.json
      def show
        render json: AccountSerializer.new(@account).serialized_json
      end

      # POST /accounts
      # POST /accounts.json
      def create
        @account = current_user.accounts.build(account_params)
        @account.save!
        render json: AccountSerializer.new(@account).serialized_json,
               status: :created,
               location: @account
      end

      # PATCH/PUT /accounts/1
      # PATCH/PUT /accounts/1.json
      def update
        @account.update!(account_params)
        render json: AccountSerializer.new(@account).serialized_json, status: :ok
      end

      # DELETE /accounts/1
      # DELETE /accounts/1.json
      def destroy
        @account.destroy
        render json: {}, status: :no_content
      end

      # Sets account active field to false
      def deactivate
        @account.active = false
        @account.save!
        render json: {}, status: :ok
      end

      # Sets account active field to true
      def activate
        @account.active = true
        @account.save!
        render json: {}, status: :ok
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_account
        @account = current_user.accounts.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def account_params
        params.require(:account).permit(:name, :starting_balance, :current_balance, :last_four, :active, :user_id)
      end
    end
  end
end