class BomsController < ApplicationController
  layout "project"
  before_filter :login_required, :only => [:new]
  
  def index
    #this method is here so the UI can call it whether there is a bom or not
    @project = session[:project]
    redirect_to projects_path and return if @project.nil?
    redirect_to new_project_bom_path(@project) and return if params[:id].nil? 
    @bom = Bom.find(params[:id])
    redirect_to new_project_bom_path(@project) and return if @bom.nil?
    redirect_to project_bom_path(@project, @bom) and return
  end
  
  def show
    #is really a list of the items in the BOM, since the BOM itself does not have any
    #  data of its own
    @project = session[:project]    
    @bom = Bom.find(params[:id])
    redirect_to new_bom_item_path(@bom) and return if @bom.items.nil? 
    @items = @bom.items_grouped
  end

  def new  #does nothing more than set name and redirect to items
    @project = Project.find(params[:project_id])
    redirect_to @project unless current_user.is_owner?(@project)
    @bom = Bom.create(:name => @project.name)
    @project.bom = @bom
    #create event   
    redirect_to new_bom_item_path(@bom)

  end

end
