class DashboardController < ApplicationController
  before_filter :login_required
  def index
    l = logged_in?
    puts l
    cu = current_user
    puts cu
    @related_projects = current_user.related_projects
    @events = current_user.related_events.paginate :page=>params[:page],  :per_page => 5
  end
end
