class SessionsController < ApplicationController
  def create
    if current_user
      current_user.update_by_oauth(omniauth_hash)
    else
      user = User.find_update_or_create_by_omniauth(omniauth_hash)

      set_current_user(user)
    end

    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
  end
end
