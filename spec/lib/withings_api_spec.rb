require 'rails_helper'

describe WithingsAPI do
  # dummy values from http://oauth.withings.com/api
  let(:consumer_key)    { '123456789' }
  let(:consumer_secret) { '123456789' }
  let(:omniauth_hash) {
    {
      provider:    'withings',
      uid:         '123',
      info:        {name: 'flada'},
      credentials: {
        token:  '9eeb4e2c976ec4d47b925392149c8bbceb5efcfd9b14441429e761052e52f',
        secret: '29d7b29209c9222169d103b766fb5783f296788500df68e8f30f0cb4d60c'
      }
    }
  }

  let(:user) { User.create_by_oauth(omniauth_hash) }
  let(:client) { WithingsAPI.new(user.withings) }

  before do
    WithingsAPI.consumer_key = consumer_key
    WithingsAPI.consumer_secret = consumer_secret
  end

  describe '#oauth_signature_key' do
    subject { client.oauth_signature_key }

    it { should eq('123456789&29d7b29209c9222169d103b766fb5783f296788500df68e8f30f0cb4d60c') }
  end

  describe '#oauth_signature_base_string' do
    let(:method) { 'GET' }
    let(:path)   { '/measure' }
    let(:parameters) {
      {
        action: 'getmeas',
        oauth_consumer_key: '123456789',
        oauth_nonce: 'dc6102cd25f7392b234a7f2f58be6260',
        oauth_signature_method: 'HMAC-SHA1',
        oauth_timestamp: '1431287241',
        oauth_token: '9eeb4e2c976ec4d47b925392149c8bbceb5efcfd9b14441429e761052e52f',
        oauth_version: '1.0',
        userid: '' # XXX
      }
    }

    subject { client.oauth_signature_base_string(method, path, parameters) }

    it { should eq('GET&http%3A%2F%2Fwbsapi.withings.net%2Fmeasure&action%3Dgetmeas%26oauth_consumer_key%3D123456789%26oauth_nonce%3Ddc6102cd25f7392b234a7f2f58be6260%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1431287241%26oauth_token%3D9eeb4e2c976ec4d47b925392149c8bbceb5efcfd9b14441429e761052e52f%26oauth_version%3D1.0%26userid%3D') }
  end

  describe '#oauth_signature' do
    let(:method) { 'GET' }
    let(:path) { '/measure' }
    let(:parameters) {
      {
        action: 'getmeas',
        oauth_consumer_key: '123456789',
        oauth_nonce: 'dc6102cd25f7392b234a7f2f58be6260',
        oauth_signature_method: 'HMAC-SHA1',
        oauth_timestamp: '1431287241',
        oauth_token: '9eeb4e2c976ec4d47b925392149c8bbceb5efcfd9b14441429e761052e52f',
        oauth_version: '1.0',
        userid: '' # XXX
      }
    }

    # Withings api page shows the Percent-encoded signature, but #oauth_signature returns not Percent-encoded signature.
    # CGI.unescape('S0Ug4SPbQzNimIcJbiXs24PVniI%3D') # => 'S0Ug4SPbQzNimIcJbiXs24PVniI='
    let(:percent_encdoed_signature)     { 'S0Ug4SPbQzNimIcJbiXs24PVniI%3D' }
    let(:not_percent_encoded_signature) { CGI.unescape(percent_encdoed_signature) }

    subject { client.oauth_signature(method, path, parameters) }

    it { should eq(not_percent_encoded_signature) }
  end
end
