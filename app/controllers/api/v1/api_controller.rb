# frozen_string_literal: true

module Api
  module V1
    class ApiController < ApplicationController
      include Concerns::TokenAuthenticatable

      rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response

      protected

      def paginate(scope, default_per_page = 10)
        collection = scope.page(params[:page]).per_page((params[:per_page] || default_per_page).to_i)

        current, total, per_page = collection.current_page, collection.total_pages, collection.limit_value

        pagination = {
          self:     current,
          per_page: per_page,
          pages:    total,
          count:    collection.count
        }
        if current > 1 then
          pagination[:prev] =  current - 1
        end
        if current != total then
          pagination[:next] =  current + 1
        end

        return [
          collection,
          pagination
        ]
      end

      private

      def render_unprocessable_entity_response(exception)
        render json: exception.record.errors, status: :unprocessable_entity
      end

      def render_not_found_response
        render json: { errors: 'Not found' }, status: :not_found
      end
    end
  end
end
