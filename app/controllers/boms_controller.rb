class BomsController < ApplicationController
  layout "project"
  before_filter :login_required, :only => [:index]
  
  def index
    @project = current_project(params[:project_id])
    redirect_to projects_path and return if @project.nil?
    @bom = @project.bom
    redirect_to project_path(@project) and return if @bom.nil?
    items = @bom_items
    puts items
    render :template=> 'boms/new'   and return if @bom.items.empty?
    redirect_to project_bom_path(@project, @bom) and return
  end

  def show
    #is really a list of the items in the BOM, since the BOM itself does not have any
    #  data of its own
    @bom = Bom.find(params[:id])
    @project = current_project(@bom.project_id)
    redirect_to new_bom_item_path(@bom) and return if @bom.items.nil?
    @items = @bom.items_grouped
  end
end


