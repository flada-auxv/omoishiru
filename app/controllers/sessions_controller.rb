class SessionsController < ApplicationController
  def create
    if current_user
      current_user.create_authentication_by_oauth(omniauth_hash)
    else
      user = User.find_or_create_by_oauth(omniauth_hash)

      set_current_user(user)
    end

    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
  end

  private

  def omniauth_hash
    env['omniauth.auth']
  end
end
