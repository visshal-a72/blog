class ApplicationController < ActionController::Base
  helper_method :current_user_session, :current_user, :logged_in?

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from ActionController::ParameterMissing, with: :bad_request

  private

  def record_not_found(exception)
    Rails.logger.warn "Record not found: #{exception.message}"
    redirect_to root_path, alert: "The requested record was not found."
  end

  def record_invalid(exception)
    Rails.logger.warn "Record invalid: #{exception.message}"
    redirect_back fallback_location: root_path, alert: "Validation failed: #{exception.record.errors.full_messages.join(', ')}"
  end

  def bad_request(exception)
    Rails.logger.warn "Bad request: #{exception.message}"
    redirect_back fallback_location: root_path, alert: "Invalid request parameters."
  end

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
