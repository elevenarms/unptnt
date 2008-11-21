class ProjectsController < ApplicationController
  include ProjectCloning
  include DocVersioning
  layout "project"
  uses_tiny_mce(:only => [:new, :edit], :options => AppConfig.default_mce_options)
  require 'will_paginate'
  before_filter :login_required, :only => [ :new, :edit, :create, :update, :destroy, :follow ]
  after_filter  :load_project, :only => [ :show, :create, :update ]
  #auto_complete_for :user, :login
  
  PROJECT_TYPES = ["Electronic",  "Embeded", "Wearable", "Mechanical", "System"]
  PROJECT_SUBTYPES_ELECTRONICS = ["Robotics", "Microcontrollers", "Audio/Video"]
  PROJECT_SUBTYPES_FURNITURE = ["Wood", "Acrylic"]
  PROJECT_SUBTYPES_WEARABLES = ["Electronic", "Knitted"]
  
  # GET /projects
  # GET /projects.xml
  def index
    @projects = Project.paginate :page=>params[:page],  :per_page => 5
    render :template => '/projects/index', :layout => 'application'
  end
  
  #get all the users who have any relationship to this project
  def related_users
    @project = Project.find(params[:id])
    if @project.nil? then 
      redirect_to projects_path and return
    end
    @related_users = @project.related_users
  end

  # GET /projects/1
  # GET /projects/1.xml
  def show
    @project = Project.find(params[:id])
    @events = @project.events
    @related_users = @project.related_users
    @doc_version = DocVersion.find_by_project_id(@project.id)
  
    respond_to do |format|
      format.html # show.html.erb
      format.js   # show.js.rjs
      format.xml  { render :xml => @project }
    end
  end
  
  def show_family_trees
    @project = Project.find(params[:id])
    @family_trees = @project.find_trees
  end

  # GET /projects/new
  # GET /projects/new.xml
  def new
    @project = Project.new
    @licenses = License.find(:all)   
    @project_types = PROJECT_TYPES
  end
  
  def new_clone
    @parent_project = Project.find(params[:id])
    @project = Project.new
  end
  

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])
    unless current_user.is_editor?(@project) then 
      redirect_to @project and return
    end    
    @licenses = License.find(:all)
    @project_types = PROJECT_TYPES
    
    respond_to do |wants|
      wants.html  # edit.html.erb
      wants.js    # edit.js.rjs
    end
  end

  # POST /projects
  # POST /projects.xml
  def create
    @project = Project.create(params[:project])
    
    #set owner
    proj_people = ProjectPerson.create(:relationship => "owner", :project_id => @project.id, :user_id => current_user.id)
    @project.project_people << proj_people
    current_user.project_people << proj_people    
    
    #set status
    unless @project.status == "" then
      status = Status.create(:status_text => params[:project][:status])
      @project.statuses << status
      status.save      
    end

    #set license
    unless params[:project][:license_id] == "" then
      license = License.find(params[:project][:license_id])
      @project.license = license      
    end
    
    #link in the tags
    proj_types = params[:tags][:proj_types_list]
    keywords = params[:tags][:keywords_list]
    @project.proj_type_list = proj_types unless proj_types.nil?
    @project.keyword_list = keywords unless keywords.nil?
    
    if @project.save        
      flash[:notice] = 'Project was successfully created.'
      #create event
      @project.create_event(Action::CREATE_PROJECT, @project, current_user)
      
      #put in clone table
      if  params[:parent_projectid].nil? then
        @project.create_root
      else
        parent_project = Project.find(params[:parent_projectid])
        clone_elements(@project, parent_project)
        @project.make_new_clone(parent_project)
      end
         
      redirect_to(@project) and return
    else     
      render :action => "new"
    end
  end

  # PUT /projects/1
  # PUT /projects/1.xml
  def update
    @project = Project.find(params[:id])
    unless current_user.is_editor?(@project) then 
      redirect_to @project and return
    end     
    unless @project.status == params[:project][:status] || params[:project][:status] == "" then
      status = Status.create(:status_text => params[:project][:status])
      @project.statuses << status
      status.save      
    end

    unless params[:project][:license_id] == "" then
      license = License.find(params[:project][:license_id])
      @project.license = license      
    end

    if @project.update_attributes(params[:project])
      flash[:notice] = 'Project was successfully updated.'
      #create event
      respond_to do |wants|
        wants.html { redirect_to :action => 'show' and return }
        wants.js   #update.js.rjs
      end
    else       
      render :action => "edit" and return
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.xml
  def destroy
    redirect_to :back and return
    #unless current_user.is_owner?(@project) then 
      #redirect_to @project
    #end    
    #create event
  
    #@project.destroy
    #redirect_to(projects_url)  and return
  end
  
  def status_history
    @project = Project.find(params[:id])
  end
  
  def follow 
    @project = Project.find(params[:id])    
    connect(@project, current_user, "follower")
    respond_to do |format| 
      format.html { redirect_to :action => 'show' }
      format.js   #follow_project.rjs
    end    
  end
  
  def stop_following
    @project = Project.find(params[:id]) 
    proj_people = ProjectPerson.find(:first, :conditions => "user_id = '#{current_user.id}' && project_id = '#{params[:id]}'")
    proj_people.destroy
    respond_to do |format|
      format.html {  redirect_to :action => 'show'  }
      format.js   #stop_following_project.rjs
    end
  end
  
  def add_collaborator
    @users = User.find(:all)
    @project = Project.find(params[:id])
    unless current_user.is_owner?(@project) then 
      redirect_to @project
    end     
  end
  
  def create_collaborator
    @project = Project.find(params[:id]) 
    unless current_user.is_owner?(@project) then 
      redirect_to @project
    end
    user = User.find(params[:userid])
    connect(@project, user,  "collaborator")
    redirect_to :action => 'related_users', :id => @project.id  and return
  end
  
  def remove_collaborator
    project = Project.find(params[:id]) 
    unless current_user.is_owner?(project) then 
      redirect_to project
    end    
    proj_person = ProjectPerson.find(:first, :conditions => "user_id = '#{params[:userid]}' && project_id = '#{project.id }'")
    proj_person.destroy
    redirect_to :action => 'related_users', :id => project.id
  end
  
  def related_users
    @project = Project.find(params[:id])
    #TO DO convert to @project.related_users
    @related_users = @project.related_users
  end 
  
  protected  #can only be called from here
  
  def connect(project, user, relationship)
    proj_person = ProjectPerson.find(:first, :conditions =>  "user_id = '#{user.id}' && project_id = '#{project.id}'")
    return if !proj_person.nil? && proj_person.relationship == relationship
    unless proj_person.nil?
      proj_person.update_attributes(:relationship => relationship)
      proj_person.save
      return
    end
    proj_people = ProjectPerson.create(:relationship => relationship, :project_id => project.id, :user_id => user.id)
    project.project_people << proj_people
    user.project_people << proj_people    
  end 
  
  private
  def load_project
    session[:project] = @project
  end
  
end
