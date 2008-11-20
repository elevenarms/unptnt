class DashboardController < ApplicationController
  before_filter :login_required 
  def index
    @user_projects = current_user.related_projects
    @invitation = Invitation.new
    @events = current_user.related_events.paginate :page=>params[:page],  :per_page => 5
  end
end
