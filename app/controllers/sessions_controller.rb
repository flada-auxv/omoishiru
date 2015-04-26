class SessionsController < ApplicationController
  def create
    user = User.find_or_create_by_auth_hash(env['omniauth.auth'])

    session[:user_id] = user.id

    redirect_to root_path, notice: 'Signed in!'
  end

  def destroy
    session[:user_id] = nil
  end
end
