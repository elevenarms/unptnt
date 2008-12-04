class PeopleController < ApplicationController
  include ProjectModule
  layout "project"
  def follow_project 
    @project = current_project(params[:id])
    connect(@project, current_user, "follower")
    respond_to do |format| 
      format.html { render :template => '/projects/show.html.erb' }
      format.js   #follow_project.rjs
    end    
  end
  
  def stop_following_project
    @project = current_project(params[:id])
    proj_people = ProjectPerson.find(:first, :conditions => "user_id = '#{current_user.id}' && project_id = '#{params[:id]}'")
    proj_people.destroy
    respond_to do |format|
      format.html { render :template => '/projects/show.html.erb' }
      format.js   #stop_following_project.rjs
    end
  end
  
  def add_collaborator
    @users = User.find(:all)
    @project = current_project(params[:id])
  end
  
  def create_collaborator
    @project = current_project(params[:projectid])
    user = User.find(params[:userid])
    connect(@project, user,  "collaborator")
    render :template => '/projects/show.html.erb' 
  end
  
  def remove_collaborator
    project = current_project(params[:projectid])
    proj_person = ProjectPerson.find(:first, :conditions => "user_id = '#{params[:userid]}' && project_id = '#{project.id }'")
    proj_person.destroy
    redirect_to :action => 'show_project_people', :id => project.id
  end
  
protected  #can only be called from here
  
  protected  #can only be called from here
  
  def connect(project, user, relationship)
    proj_person = ProjectPerson.find(:first, :conditions =>  "user_id = '#{user.id}' && project_id = '#{project.id}'")
    return if !proj_person.nil? && proj_person.relationship == relationship
    unless proj_person.nil?
      proj_person.relationship = relationship
      return
    end
    proj_people = ProjectPerson.create(:relationship => relationship, :project_id => project.id, :user_id => user.id)
    project.project_people << proj_people
    user.project_people << proj_people    
  end 
  
end
