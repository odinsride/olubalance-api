# frozen_string_literal: true

# User class
class User < ApplicationRecord
  has_secure_password

  validates :password, presence: true, if: -> { new_record? || changes[:password_digest] }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || changes[:password_digest] }

  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:password_digest] }

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: /@/
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :timezone, presence: true

  has_many :accounts, dependent: :destroy
end
