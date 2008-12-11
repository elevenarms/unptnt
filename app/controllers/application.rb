# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  require 'ruby-debug'
  helper :all # include all helpers, all the time
  include AuthenticatedSystem

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'bd844a0e54e15f3ff6867d9170c994ec'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  def tab_link_to(name, options = {}, html_options = {})
    html_options.merge!({ :id => 'current' }) if current_page?(options)
    link_to name, options, html_options
  end
  #this goes in the view <% tab_link_to 'Companies', companies_path %>


  def current_project(id)
    #gets either the session project or retrieves one from the database
    return session[:project] if !session[:project].nil? && session[:project][:id] == id
    project = Project.find(id)
    session[:project] = project
    return project
  end
  
end
