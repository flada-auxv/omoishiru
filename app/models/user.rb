class User < ActiveRecord::Base
  class << self
    def find_update_or_create_by_omniauth(omniauth_hash)
      user = find_or_create_by("#{omniauth_hash.provider}_uid" => omniauth_hash.uid)
      user.update("#{omniauth_hash.provider}_name" => omniauth_hash.info.name)
      user
    end
  end
end
