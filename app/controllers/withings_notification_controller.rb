require 'withings_api'

class WithingsNotificationController < ApplicationController
  before_action :pong,     only: :callback, if: 'request.head?'
  before_action :set_user, only: :callback

  before_action :set_client

  def subscribe
    res = @withings.create_notification(withings_callback_url, 'test')

    logger.debug res.inspect

    redirect_to :root
  end

  def callback
    res = @withings.get_body_measures

    logger.debug res.inspect

    # XXX いい感じにオブジェクト化したい
    res_hash = JSON.parse(res.body).with_indifferent_access
    latest_measure = res_hash[:body][:measuregrps].sort_by {|h| h[:date] }.reverse.first
    weight = latest_measure[:measures].find {|h| h[:type] == 1 }
    real_value = (weight[:value] * (10 ** weight[:unit])).to_f

    @twitter.update_profile(name: real_value.to_s)

    head :ok
  end

  private

  def pong
    head :ok and return
  end

  def set_user
    user = User.includes(:authentications).find_by!(authentications: {provider: :withings, uid: params[:userid]})

    set_current_user(user)
  end

  def set_client
    @withings = WithingsAPI.new do |config|
      config.consumer_key    = ENV['WITHINGS_CONSUMER_KEY']
      config.consumer_secret = ENV['WITHINGS_CONSUMER_SECRET']
      config.uid             = current_user.withings.uid
      config.token           = current_user.withings.token
      config.token_secret    = current_user.withings.token_secret
    end

    @twitter = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = current_user.twitter.token
      config.access_token_secret = current_user.twitter.token_secret
    end
  end
end
