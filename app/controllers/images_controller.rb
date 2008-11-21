class ImagesController < ApplicationController
  
  def new
    @project = @item = nil
    if !params[:project_id].nil?  then
      redirect_to projects_path and return if (@project = Project.find(params[:project_id])).nil?
    elsif !parmas[:item_id].nil?
      redirect_to @project and return if (@item = Item.find(params[:item_id])).nil?
    else redirect_to projects_path and return
    end
    respond_to do |wants|
      wants.html  # new.html.erb
      wants.js    # new.js.rjs
    end
  end
  
  def edit
    @project = @item = nil
    if !params[:project_id].nil?  then
      redirect_to projects_path and return if (@project = Project.find(params[:project_id])).nil?
    elsif !parmas[:item_id].nil?
      redirect_to @project and return if (@item = Item.find(params[:item_id])).nil?
    else redirect_to projects_path and return
    end
    respond_to do |wants|
      wants.html  # edit.html.erb
      wants.js    # edit.js.rjs
    end
  end
  
  def show
    
    
  end
end
