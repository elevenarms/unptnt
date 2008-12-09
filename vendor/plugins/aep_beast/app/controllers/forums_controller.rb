class ForumsController < ApplicationController
  include ProjectModule
	before_filter :login_required, :except => [:show]
  cache_sweeper :posts_sweeper, :only => [:create]

  def show
    #is there already a forum to show???
    if params[:id] == "0" then
      redirect_to :back and return unless logged_in?
      if !params[:item_id].nil? then
        @subject_id = params[:item_id]
        @subject_type = 'item'
        @name = Item.find(params[:item_id]).name
        @bom = Item.find(params[:item_id]).bom
      else
        project = current_project(params[:project_id])
        @name = project.name
        @subject_id = params[:project_id]
        @subject_type = 'project'
      end
      render :template => 'forums/new' and return
    end
    @forum = Forum.find(params[:id])
    respond_to do |format|
      format.html do
        # keep track of when we last viewed this forum for activity indicators
        (session[:forums] ||= {})[@forum.id] = Time.now.utc if logged_in?
        (session[:forum_page] ||= Hash.new(1))[@forum.id] = params[:page].to_i if params[:page]

        @topics = @forum.topics.paginate :page => params[:page]
        User.find(:all, :conditions => ['id IN (?)', @topics.collect { |t| t.replied_by }.uniq]) unless @topics.blank?
      end
      format.xml { render :xml => @forum }
    end
  end
  
  def create
    #this is called when we need to create a forum for an item or project.
    @forum = Forum.create(params[:forum])
    respond_to do |format|
      format.html { redirect_to @forum }
      format.xml  { head :created, :location => formatted_forum_url(@forum, :xml) }
    end
  end

end
