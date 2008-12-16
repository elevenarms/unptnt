class BookmarkletsController < ApplicationController
  layout 'bookmarklet'
  ITEM_TYPES = ["Hardware", "Software", "Tools"]
  
  def new
    @projects = Project.find(:all)
    @item = Item.new(:name => params[:t], :info_url => params[:u])

    @item_types = ITEM_TYPES  
    @s = params[:s]    
    @t = params[:t]
    @u = params[:u]
    @v = params[:v]
  end

  def create   
    if params[:project_id] == "" then
      add_error("You must select a project to which this part is added")
      redirect_to :action => 'new', :s => params[:s], :t => params[:t], :u => params[:u], :v => params[:v]  and return
    end 
    Project.find(params[:project_id]).get_bom.items << Item.create(params[:item])
  end
end
