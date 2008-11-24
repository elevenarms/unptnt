class ImagesController < ApplicationController
  
  def new
    @project = @item = nil
    @image = { :id => 0 }
    if !params[:project_id].nil?  then
      redirect_to projects_path and return if (@project = Project.find(params[:project_id])).nil?
    elsif !params[:item_id].nil? then
      redirect_to @project and return if (@item = Item.find(params[:item_id])).nil?
      # new item image
      @bom = @item.bom
      respond_to do |wants|
        wants.html
        wants.js   { render :template => 'images/new_in_item' }
      end  
      return
    else
      redirect_to projects_path and return
    end
    # new project image
    
    respond_to do |wants|
      wants.html
      wants.js   { render :template => 'images/new_in_project' }
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
    @project = @item = nil
    @image = { :id => 0 }
    if !params[:project_id].nil?  then
      redirect_to projects_path and return if (@project = Project.find(params[:project_id])).nil?
    elsif !params[:item_id].nil? then
      redirect_to @project and return if (@item = Item.find(params[:item_id])).nil?
      # new item image
      @bom = @item.bom
      @project = session[:project]
      respond_to do |wants|
        wants.html
        wants.js   { render :template => 'images/show_in_item' }
      end  
      return
    else
      redirect_to projects_path and return
    end
    # new project image
    
    respond_to do |wants|
      wants.html
      wants.js    { render :template => 'images/show_in_project' }
    end
  end
end
