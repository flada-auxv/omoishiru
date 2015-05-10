class User < ActiveRecord::Base
  has_many :authentications

  class << self
    def find_or_create_by_oauth(auth_hash)
      find_by_authentications(auth_hash[:provider], auth_hash[:uid]) || create_by_oauth(auth_hash)
    end

    def find_by_authentications(provider, uid)
      includes(:authentications).find_by(authentications: {provider: provider, uid: uid})
    end

    def create_by_oauth(auth_hash)
      create do |user|
        user.authentications.build do |auth|
          auth.provider     = auth_hash[:provider]
          auth.uid          = auth_hash[:uid]
          auth.name         = auth_hash[:info][:name]
          auth.token        = auth_hash[:credentials][:token]
          auth.token_secret = auth_hash[:credentials][:secret]
        end
      end
    end
  end

  def create_authentication_by_oauth(auth_hash)
    authentications.create do |auth|
      auth.provider     = auth_hash[:provider]
      auth.uid          = auth_hash[:uid]
      auth.name         = auth_hash[:info][:name]
      auth.token        = auth_hash[:credentials][:token]
      auth.token_secret = auth_hash[:credentials][:secret]
    end
  end

  %i(twitter withings).each do |provider|
    define_method provider do
      authentications.find_by(provider: provider)
    end
  end
end
