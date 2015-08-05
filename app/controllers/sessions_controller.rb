class SessionsController < ApplicationController

  def login
    render :login
  end

  def create
    auth_hash = request.env['omniauth.auth']
    session[:user] = auth_hash["info"]["last_name"]
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path :flash => "Signed Out!"
  end

  def create_instagram
    request.env["omniauth.auth"]
  end

  def create_vimeo
    auth = request.env["omniauth.auth"]
    authenticated_user = AuthenticatedUser.find_by_provider_and_uid(auth["provider"], auth["uid"]) || AuthenticatedUser.create_with_omniauth(auth)
    session[:user_id] = authenticated_user.id
    redirect_to root_url :notice => "Signed in!"
  end


end
