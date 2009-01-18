class DashboardController < ApplicationController
  before_filter :login_required
  def index
    @related_projects = current_user.related_projects
    @events = current_user.related_events.paginate :page=>params[:page],  :per_page => 5
  end
end
