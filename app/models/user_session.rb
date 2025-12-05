class UserSession < Authlogic::Session::Base
  # Tell Authlogic to use email as the login field
  find_by_login_method :find_by_email
end
