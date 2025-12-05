class ApplicationController < ActionController::Base
  helper_method :current_user_session, :current_user, :logged_in?

  private

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session&.record
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    unless logged_in?
      flash[:alert] = "You must be logged in to access this page."
      redirect_to login_path
    end
  end

  def require_no_login
    if logged_in?
      flash[:notice] = "You are already logged in."
      redirect_to root_path
    end
  end
end
