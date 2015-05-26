require 'withings_api/client'

class Api::WithingsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action ->{ head :ok and return }, if: ->{ request.head? }
  before_action :set_user, :set_client

  def callback
    # XXX いったん Weight のみに絞る
    res = @withings.get_body_measures({meastype: 1})

    logger.debug res.inspect

    # XXX いい感じにオブジェクト化したい
    res_hash = JSON.parse(res.body).with_indifferent_access
    latest_measure = res_hash[:body][:measuregrps].sort_by {|h| h[:date] }.reverse.first
    weight = latest_measure[:measures].find {|h| h[:type] == 1 }

    real_value = weight ? (weight[:value] * (10 ** weight[:unit])).to_f : ''

    @twitter.update(<<-BODY.strip_heredoc)
      Weight: #{real_value.to_s}
      #omoishiru
    BODY
    @twitter.update_profile(name: real_value.to_s)

    head :ok
  end

  private

  def set_user
    user = User.includes(:authentications).find_by!(authentications: {provider: :withings, uid: params[:userid]})

    set_current_user(user)
  end

  def set_client
    @withings = WithingsApi::Client.new do |config|
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
