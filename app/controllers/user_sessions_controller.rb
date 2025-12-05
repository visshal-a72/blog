class UserSessionsController < ApplicationController
  before_action :require_no_login, only: [:new, :create]
  before_action :require_login, only: [:destroy]

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(user_session_params.to_h)
    
    if @user_session.save
      flash[:notice] = "Welcome back, #{@user_session.record.name}!"
      redirect_to root_path
    else
      flash.now[:alert] = "Invalid email or password."
      render :new
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = "You have been logged out."
    redirect_to root_path
  end

  private

  def user_session_params
    params.require(:user_session).permit(:email, :password, :remember_me)
  end
end
