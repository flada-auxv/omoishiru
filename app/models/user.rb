class User < ActiveRecord::Base
  class << self
    def find_or_create_by_auth_hash(auth)
      find_or_create_by("#{auth[:provider]}_uid" => auth[:uid])
    end
  end
end
