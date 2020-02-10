# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApiController
      before_action :set_user, only: %i[show update destroy]
      skip_before_action :authenticate_user, only: %i[create]

      def create
        @user = User.new(user_params)
        if @user.save
          @user = UserSerializer.new(@user).serializable_hash
          render json: @user, status: :created
        else
          render json: { errors: @user.errors.full_messages }, status: :bad_request
        end
      end

      def show
        render json: UserSerializer.new(@user).serializable_hash, status: :ok
      end

      def update
        if @user.update(user_params)
          render json: UserSerializer.new(@user).serializable_hash, status: :ok
        else
          render json: { errors: @user.errors.full_messages }, status: :bad_request
        end
      end

      def destroy
        @user.destroy
        render json: {}, status: :no_content
      end

      private

      def user_params
        params.require(:user)
              .permit(:email,
                      :password,
                      :password_confirmation,
                      :first_name,
                      :last_name,
                      :timezone)
      end

      def set_user
        @user = current_user
      end
    end
  end
end
