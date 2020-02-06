# frozen_string_literal: true

module Api
  module V1
    class AuthenticationController < ApiController
      skip_before_action :authenticate_user

      def authenticate
        token_command = AuthenticateUserCommand.call(params[:email], params[:password])

        if token_command.success?
          render json: { email: params[:email], jwt: token_command.result }
        else
          render json: { error: token_command.errors }, status: :unauthorized
        end
      end
    end
  end
end
