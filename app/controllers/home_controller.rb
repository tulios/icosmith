class HomeController < ApplicationController

  def index
    skip_session
    expires_in 15.minutes, public: true
  end

end
