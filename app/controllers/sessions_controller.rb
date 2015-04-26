class SessionsController < ApplicationController
  def create
    user = User.find_update_or_create_by_omniauth(omniauth_hash)

    session[:user_id] = user.id

    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
  end
end
