require 'withings_api'

class WithingsNotificationController < ApplicationController
  before_action :set_client

  def subscribe
    res = @withings.create_notification(api_withings_callback_url, 'test')

    logger.debug res.inspect

    redirect_to :root
  end

  private

  def set_client
    @withings = WithingsAPI.new do |config|
      config.consumer_key    = ENV['WITHINGS_CONSUMER_KEY']
      config.consumer_secret = ENV['WITHINGS_CONSUMER_SECRET']
      config.uid             = current_user.withings.uid
      config.token           = current_user.withings.token
      config.token_secret    = current_user.withings.token_secret
    end
  end
end
