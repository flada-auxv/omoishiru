class User < ActiveRecord::Base
  class << self
    def find_update_or_create_by_omniauth(omniauth_hash)
      user = find_or_create_by("#{omniauth_hash.provider}_uid" => omniauth_hash.uid)
      user.update_by_oauth(omniauth_hash)
      user
    end
  end

  def update_by_oauth(omniauth_hash)
    attrs = {"#{omniauth_hash.provider}_name" => omniauth_hash.info.name}

    unless attributes["#{omniauth_hash.provider}_uid"]
      attrs.merge!("#{omniauth_hash.provider}_uid" => omniauth_hash.uid)
    end

    update(attrs)
  end
end
