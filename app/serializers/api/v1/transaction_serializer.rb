# frozen_string_literal: true

module Api
  module V1
    class TransactionSerializer < ApplicationSerializer
      attribute :date, &:trx_date
      attributes :description, :amount, :memo,
                 :running_balance, :attachment_url, :attachment_thumb_url,
                 :created_at, :updated_at
      belongs_to :account

      attribute :attachment_url do |object|
        Rails.application.routes.url_helpers.rails_blob_url(object.attachment) if object.attachment.attached?
      end

      attribute :attachment_thumb_url do |object|
        Rails.application.routes.url_helpers.rails_representation_url(object.attachment.variant(resize: '100x100')) if object.attachment.attached?
      end
    end
  end
end
