class ForumsController < ApplicationController
  include ProjectModule
	before_filter :login_required, :except => [:show]
  cache_sweeper :posts_sweeper, :only => [:create]

  def show
    #is there already a forum to show???
    if params[:id] == "0" then
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
      @forum = Forum.create(params[:forum])
      render :template => 'forums/new' and return
    end
    @forum = Forum.find(params[:id])
    render :template => 'forums/new' and return if @forum.topics_count == 0
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
    #when this is called, we already have created the forum.  Need to create the first topic and post
    redirect_to new_forum_topic_path(params[:forum][:forum_id])
  end

end
