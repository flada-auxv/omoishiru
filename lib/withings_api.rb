class WithingsAPI
  BASE_URI = 'http://wbsapi.withings.net'

  class_attribute :consumer_key, :consumer_secret

  def initialize(withings_authentication)
    @conn = Faraday.new(url: BASE_URI)

    @withings = withings_authentication
  end

  def oauth_signature(method, path, options)
    base_string = oauth_signature_base_string(method, path, options)

    digest = OpenSSL::HMAC.digest('sha1', oauth_signature_key, base_string)
    Base64.strict_encode64(digest)
  end

  def oauth_signature_base_string(method, path, options)
    options_str = options.map {|key, value| "#{key}=#{value}"}.sort.join('&')

    [method, CGI.escape(BASE_URI + path), CGI.escape(options_str)].join('&')
  end

  def oauth_signature_key
    [CGI.escape(self.class.consumer_secret), CGI.escape(@withings.token_secret)].join('&')
  end

  def oauth_options
    {
      oauth_consumer_key: self.class.consumer_key,
      oauth_nonce: SecureRandom.hex,
      oauth_signature_method: 'HMAC-SHA1',
      oauth_timestamp: Time.now.to_i,
      oauth_token: @withings.token,
      oauth_version: '1.0'
    }
  end

  def get(path, options)
    opts = options.update(oauth_options)

    signature = oauth_signature('GET', path, opts)

    @conn.get(path, opts.merge(oauth_signature: signature))
  end

  def list_notifications
    get('/notify', action: :list, userid: @withings.uid)
  end
end
