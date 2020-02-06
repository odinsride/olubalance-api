# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :set_timezone

  private

  def set_timezone
    tz = @current_user ? @current_user.timezone : nil
    Time.zone = tz || ActiveSupport::TimeZone['UTC']
  end
end
