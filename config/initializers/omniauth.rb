Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_CONSUMER_SECRET']
  provider :withings, ENV['WITHINGS_CONSUMER_KEY'], ENV['WITHINGS_CONSUMER_SECRET']
end
