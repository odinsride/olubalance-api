# frozen_string_literal: true

class AccountDecorator < ApplicationDecorator
  decorates_finders
  decorates_association :user
  decorates_association :transaction
  delegate_all
  include Draper::LazyHelpers

  # Display the account name with last four if present
  def d_account_name
    last_four.present? ? name + ' ( ... ' + last_four.to_s + ')' : name
  end

  # Check if the account name is longer than the display limit for account cards
  def name_too_long
    name.length > Account::DISPLAY_NAME_LIMIT
  end

  # Truncate the account name on Accound cards if too long
  def d_account_card_title
    name_too_long ? name[0..Account::DISPLAY_NAME_LIMIT] + '...' : name
  end

  # Display the last four digits of the account
  def d_last_four
    last_four.present? ? 'xx' + last_four.to_s : nil
  end

  # Display the current account balance in currency format
  def d_current_balance
    number_to_currency(current_balance)
  end

  # Display the pending account balance in currency format
  def d_pending_balance
    number_to_currency(pending_balance)
  end

  # Display the non-pending account balance in currency format
  def d_non_pending_balance
    number_to_currency(non_pending_balance)
  end

  # Display the account name with current balance
  def d_account_name_balance
    name + ' (' + d_current_balance + ')'
  end

  # Display the descriptive last updated at date for the account
  def d_updated_at
    updated_at.in_time_zone(self.user.timezone).strftime('%b %d, %Y @ %I:%M %p %Z')
  end

  # Simple check if the account balance is negative
  def balance_negative?
    current_balance.negative?
  end

  # Set the balance color to red if the amount is negative
  def balance_color
    balance_negative? ? 'has-text-danger' : 'has-text-grey'
  end
end
