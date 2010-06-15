require 'digest/sha1'

class Admin::SessionsController < ApplicationController
  layout 'login'

  def show
    if using_open_id?
      create
    else
      redirect_to :action => 'new'
    end
  end

  def new
  end

  def create
    return successful_login if allow_login_bypass? && params[:bypass_login]
    cred = [params[:username], Digest::SHA1.hexdigest(params[:password])].join("-")

    if config.author_username_and_passwords.include?(cred)
      return successful_login
    else
      flash.now[:error] = "You are not authorized"
    end
    render :action => "new"
  end

  def destroy
    session[:logged_in] = false
    redirect_to('/')
  end

protected

  def successful_login
    session[:logged_in] = true
    redirect_to(admin_dashboard_path)
  end

  def allow_login_bypass?
    %w(development test).include?(Rails.env)
  end
  helper_method :allow_login_bypass?
end
