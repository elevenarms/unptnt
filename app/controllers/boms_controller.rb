class BomsController < ApplicationController
  layout "project"
  tab :materials
  def index
    @project = current_project(params[:project_id])
    redirect_to projects_path and return if @project.nil?
    @forum = @project.forum
    @bom = @project.bom
    redirect_to project_path(@project) and return if @bom.nil?
    items = @bom_items
    render :template=> 'boms/new'   and return if @bom.items.empty?
    redirect_to project_bom_path(@project, @bom) and return
  end

  def show
    #is really a list of the items in the BOM, since the BOM itself does not have any
    #  data of its own
    @bom = Bom.find(params[:id])
    @project = current_project(@bom.project_id)
    @forum = @project.forum
    redirect_to @project and return if @bom.items.empty?
    @items = @bom.items_grouped
  end
end


