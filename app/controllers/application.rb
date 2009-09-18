require 'redcloth'
require 'tzinfo'

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  
  include ExceptionNotifiable
  
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  
  # If you want "remember me" functionality, add this before_filter to Application Controller
  # before_filter :login_from_cookie
  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => 'ditag_secret_session_id'
  
  ActiveScaffold.set_defaults do |config| 
    config.ignore_columns.add [:created_at, :updated_at, :lock_version]
  end
  
  helper_method :text_to_html
  def text_to_html(text)
    #text.gsub("\n", "<br/>")
    RedCloth.new(text, [:hard_breaks]).to_html
  end
  
  around_filter :set_user_timezone
  
  private
  
  def set_user_timezone
    # when having current_user with time_zone prop - this line should be uncommented
    #TzTime.zone = current_user.time_zone 
    TzTime.zone = TimeZone["Eastern Time (US & Canada)"] # for now hardcode EDT timezone
    yield
    TzTime.reset!
  end
end