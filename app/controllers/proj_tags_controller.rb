class ProjTagsController < ApplicationController
  
  #get all the tags of a particular class for a project
  def index
  end

  #for a specific tag value, show all projects and users who have that tag
  def show
    @tag = Tag.find(params[:id])
    @projects = Project.tagged_with(@tag[:name], :on => 'proj_types') + Project.tagged_with(@tag[:name], :on => 'keywords')
    @users = User.tagged_with(@tag[:name], :on => 'proj_types') + User.tagged_with(@tag[:name], :on => 'keywords')
  end

  #set up for the addition of a new   
  def new
  end

  def create
  end

  def destroy
  end

end
