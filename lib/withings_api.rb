require 'faraday_middleware'

class WithingsAPI
  BASE_URI = 'http://wbsapi.withings.net'

  attr_accessor :consumer_key, :consumer_secret, :uid, :token, :token_secret

  def initialize(options = {})
    @conn = Faraday.new(url: BASE_URI) do |conn|
      conn.adapter Faraday.default_adapter

      conn.response :mashify
      conn.response :json
    end

    options.each do |key, value|
      instance_variable_set("@#{key}", value)
    end

    yield(self) if block_given?
  end

  def oauth_signature(method, path, options)
    base_string = oauth_signature_base_string(method, path, options)

    digest = OpenSSL::HMAC.digest('sha1', oauth_signature_key, base_string)
    Base64.strict_encode64(digest)
  end

  def oauth_signature_base_string(method, path, options)
    options_str = options.map {|key, value| "#{key}=#{CGI.escape(value.to_s)}"}.sort.join('&')

    [method, CGI.escape(BASE_URI + path), CGI.escape(options_str)].join('&')
  end

  def oauth_signature_key
    [CGI.escape(@consumer_secret), CGI.escape(@token_secret)].join('&')
  end

  def oauth_options
    {
      oauth_consumer_key: @consumer_key,
      oauth_nonce: SecureRandom.hex,
      oauth_signature_method: 'HMAC-SHA1',
      oauth_timestamp: Time.now.to_i,
      oauth_token: @token,
      oauth_version: '1.0'
    }
  end

  def get(path, options)
    opts = options.update(oauth_options)

    signature = oauth_signature('GET', path, opts)

    @conn.get(path, opts.merge(oauth_signature: signature))
  end

  def get_body_measures(options = {})
    opts = options.merge(action: :getmeas, userid: @uid)

    get('/measure', opts)
  end

  def create_notification(callback_url, comment, options = {})
    opts = options.merge({
      callbackurl: callback_url,
      comment: comment,
      action: :subscribe,
      userid: @uid
    })

    get('/notify', opts)
  end

  def list_notifications(options = {})
    opts = options.merge(action: :list, userid: @uid)

    get('/notify', opts)
  end

  def revoke_notification(options = {})
    opts = options.merge(action: :revoke, userid: @uid)

    get('/notify', opts)
  end
end
