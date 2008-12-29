class DocVersionsController < ApplicationController
  include ProjectModule
  include DocVersioning
  layout 'project'
  uses_tiny_mce(:only => [:new, :edit], :options => AppConfig.default_mce_options)
  
  def index
    #returns a set of doc_versions depending on how it was called:
    #  if for item or project, gets metadata for all CURRENT versions
    #  if for user, gets metadata for all VERSIONS where user is the editor
    unless params[:user_id].nil? then
      @doc_versions = DocVersions.find_by_user_id(params[:user_id], :order => 'created_at DESC')
      @user = User.find(params[:user_id])
      @domain = "user"
      return
    end
    unless params[:item_id].nil? then
      @doc_versions = DocVersion.find_current_for_item(params[:item_id]) 
      @item = Item.find(params[:item_id])
      @domain = "item"
    end
    unless params[:project_id].nil? then
      @doc_versions = DocVersion.find_current_for_project(params[:project_id]) 
      @project = session[:project]
      @domain = "project"
    end
  end
  
  def show
      @doc_version = DocVersion.find(params[:id])
      setup_ids(params)
  end
  
  def new
    #setup for the creation the first version of a new title (document)
    #  need to figure out if an item or project doc and which item or project
    @doc_version = DocVersion.new    
    if params[:project_id].nil? && params[:item_id].nil? then
      add_error("Cannot create a document without an associated project or item")
      redirect_to projects_path
    else
      setup_ids(params)
      respond_to do |wants|
        wants.html # new.html.erb
        wants.js   # new.js.rjs
      end
    end    
  end
  
  def create    
    @doc_version = make_new_doc
    if @doc_version.save then
      setup_ids(params)
      respond_to do |wants|
        wants.html { add_message("Successfully created doc version.")
          redirect_to @doc_version and return
        }
        wants.js  do
          setup_ids(params)
          render :template => 'doc_versions/show'
        end
      end
    else
      add_error(" Document not created")
    end 
  end
  
  def edit
    @doc_version = DocVersion.find(params[:id])
    @doc_version.doc_type == "item" ? @item = @doc_version.item : @item = { :id => 0 }
    @project = @doc_version.project 
    @bom = @project.bom
    @home_page = false
    # can only edit current version
    redirect_to @doc_version unless @doc_version.current_version
    respond_to do |what|
      what.html #edit.html.erb
      what.js   #edit.js.rjs
    end
  end
  
  def update
    @doc_version = DocVersion.find(params[:id])
    @project = current_project(@doc_version.project_id)
    #if current editor is same as editor or current version, just save; else make new version
    redirect_to projects_path and return if @doc_version.nil?
    @doc_version.num_edits = @doc_version.num_edits + 1
    @doc_version.content = params[:doc_version][:content]
    @doc_version.title = params[:doc_version][:title]
    @doc_version.save
    respond_to do |wants|
      wants.html { add_message("Successfully created doc version.")
        redirect_to @doc_version and return     
      }
      wants.js  do
       setup_ids(params)
       render :template => 'doc_versions/show'
      end
    end     
  end
  
  def destroy
    @doc_version = DocVersion.find(params[:id])
    @doc_version.destroy
    @project = current_project(params[:project_id])
    add_message("Successfully destroyed doc version.")
    redirect_to project_doc_versions_path(@project)
  end

  def setup_ids(params)
     unless params[:item_id].nil? || params[:item_id] == "0" then
      @item = Item.find(params[:item_id])
      @bom = @item.bom
      @home_page = true if @item.doc_versions.size == 0
      @project = current_project(@bom.project_id) and return
    else
      @item = { :id => 0 }
    end
    unless params[:project_id].nil? then
      @project = current_project(params[:project_id])
      @home_page = true if @project.doc_versions.size == 0
    end
    @current_user_is_editor = current_user.is_editor?(@project) if logged_in?
  end
end
