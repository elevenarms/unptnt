class CloneTreesController < ApplicationController
  
  
  
  
  def index
    @clone_trees = CloneTree.find(:all)
  end
  
  def show
    @clone_tree = CloneTree.find(params[:id])
  end
  
  def new
    @clone_tree = CloneTree.new
  end
  
  def create
    @clone_tree = CloneTree.new(params[:clone_tree])
    if @clone_tree.save
      flash[:notice] = "Successfully created clonetree."
      redirect_to @clone_tree
    else
      render :action => 'new'
    end
  end
  
  def edit
    @clone_tree = CloneTree.find(params[:id])
  end
  
  def update
    @clone_tree = CloneTree.find(params[:id])
    if @clone_tree.update_attributes(params[:clone_tree])
      flash[:notice] = "Successfully updated clonetree."
      redirect_to @clone_tree
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @clone_tree = CloneTree.find(params[:id])
    @clone_tree.destroy
    flash[:notice] = "Successfully destroyed clonetree."
    redirect_to clone_trees_url
  end
end
