require 'rails_helper'

describe WithingsAPI do
  # random hex numbers
  let(:consumer_key)    { '974d0ffdff081d8cd95f0e0b8f23b2e5' }
  let(:consumer_secret) { '9b057c4e64a71deb1d033084da385f89' }
  let(:uid)             { 'dfd0d5689bdc3584664d905bde4065b9' }
  let(:token)           { '375a2102f385c2ca91893dfac3c8f21d' }
  let(:token_secret)    { '3386bbe192d2277b54c0e77115b7c0af' }

  let(:client) {
    WithingsAPI.new do |config|
      config.consumer_key    = consumer_key
      config.consumer_secret = consumer_secret
      config.uid             = '123'
      config.token           = token
      config.token_secret    = token_secret
    end
  }

  describe '#oauth_signature_key' do
    subject { client.oauth_signature_key }

    it { should eq('9b057c4e64a71deb1d033084da385f89&3386bbe192d2277b54c0e77115b7c0af') }
  end

  describe '#oauth_signature_base_string' do
    let(:method) { 'GET' }
    let(:path)   { '/measure' }
    let(:parameters) {
      {
        action:                 'getmeas',
        oauth_consumer_key:     consumer_key,
        oauth_nonce:            nonce,
        oauth_signature_method: 'HMAC-SHA1',
        oauth_timestamp:        timestamp,
        oauth_token:            token,
        oauth_version:          '1.0',
        userid:                 uid
      }
    }

    # dummy values from http://oauth.withings.com/api
    let(:nonce)     { '2d982f07b0ed81df704a5712f3d73aee' }
    let(:timestamp) { '1431449286' }

    subject { client.oauth_signature_base_string(method, path, parameters) }

    it { should eq('GET&http%3A%2F%2Fwbsapi.withings.net%2Fmeasure&action%3Dgetmeas%26oauth_consumer_key%3D974d0ffdff081d8cd95f0e0b8f23b2e5%26oauth_nonce%3D2d982f07b0ed81df704a5712f3d73aee%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1431449286%26oauth_token%3D375a2102f385c2ca91893dfac3c8f21d%26oauth_version%3D1.0%26userid%3Ddfd0d5689bdc3584664d905bde4065b9') }
  end

  describe '#oauth_signature' do
    let(:method) { 'GET' }
    let(:path)   { '/measure' }
    let(:parameters) {
      {
        action:                 'getmeas',
        oauth_consumer_key:     consumer_key,
        oauth_nonce:            nonce,
        oauth_signature_method: 'HMAC-SHA1',
        oauth_timestamp:        timestamp,
        oauth_token:            token,
        oauth_version:          '1.0',
        userid:                 uid
      }
    }

    # dummy values from http://oauth.withings.com/api
    let(:nonce)     { '2d982f07b0ed81df704a5712f3d73aee' }
    let(:timestamp) { '1431449286' }

    # Withings api page shows the Percent-encoded signature, but #oauth_signature returns not Percent-encoded signature.
    let(:percent_encdoed_signature)     { '9rXo12%2BsGkuGCrlH3XQUrlBX%2FKA%3D' }
    let(:not_percent_encoded_signature) { CGI.unescape(percent_encdoed_signature) }

    subject { client.oauth_signature(method, path, parameters) }

    it { should eq(not_percent_encoded_signature) }
  end
end
