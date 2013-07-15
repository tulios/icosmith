class ApplicationController < ActionController::Base
  protect_from_forgery

  protected
  def skip_session
    request.session_options[:skip] = true
  end

end
