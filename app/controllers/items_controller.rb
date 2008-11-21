class ItemsController < ApplicationController
  layout 'project'
  include DocVersioning
  before_filter :login_required, :only => [ :new, :edit, :create, :update, :destroy ]
  after_filter  :load_item_and_bom, :only => [ :show, :create, :update ]
  
 ITEM_TYPES = ["Hardware", "Software", "Tools"] 
 
  # GET /items
  # GET /items.xml
  #def index
    #@bom = Bom.find(params[:bom_id])
    #redirect_to :action => 'new' and return if @bom.items.nil? 
    #@items = @bom.items

   # respond_to do |format|
      #format.html # index.html.erb
      #format.xml  { render :xml => @items }
    #end
  #end

  # GET /bom/1/items/1
  # bom_item_path (@bom, @item)
  def show
    @bom = Bom.find(params[:bom_id])
    @project = session[:project]
    @item = Item.find(params[:id])
    @file_attachments = @item.file_attachments
    @doc_version = doc_version_to_display(1, @item.id)
    @project = @bom.project
    @item_to_show = params[:item_to_show]
    respond_to do |what|
      what.html # show.html.erb
      what.js   # show.js.rjs        
    end
  end

  # GET  /bom/1/items/new
  #new_bom_item_path(@bom)
  def new
    @bom = Bom.find(params[:bom_id])
    @project = Project.find(@bom.project_id)
    @item = Item.new
    @item_types = ITEM_TYPES
    @doc_version = DocVersion.new
    @project = @bom.project
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @item }
    end
  end

  # GET  /bom/1/items/1/edit
  #edit_bom_item_path(@bom)
  def edit
    @bom = Bom.find(params[:bom_id])
    @project = Project.find(@bom.project_id)
    unless current_user.is_editor?(@bom.project) then 
      redirect_to @bom and return
    end    
    @item = Item.find(params[:id])
    @item_types = ITEM_TYPES
    @file_attachments = @item.file_attachments
    @doc_version = doc_version_to_display(0, @item.id)
    @project = @bom.project
    respond_to do |what|
      what.html # edit.html.erb
      what.js   #edit.rjs
    end
  end

  # POST /items
  def create 
    @bom = Bom.find(params[:bom_id]) 
    
    project = @bom.project
    @project = Project.find(@bom.project_id)
      unless current_user.is_editor?(project) then 
      redirect_to @bom and return
    end    
    @item = Item.create(params[:item])
    @bom.items << @item
    unless params[:file_attachment].nil? || params[:file_attachment][:uploaded_data] == ""  then
      @file_attachment = FileAttachment.create(params[:file_attachment])
      @item.file_attachments << @file_attachment
    end
    
      if @item.save && @bom.save
        
        flash[:notice] = 'Item was successfully created.'
        #create event
        project.create_event(Action::CREATE_ITEM, @item, current_user)
            
         redirect_to @bom  and return
      else
      render :action => "new" 
      end
    end

  # PUT /items/1
  def update
    @bom = Bom.find(params[:bom_id])
    project = @bom.project
    unless current_user.is_editor?(project) then 
      redirect_to @bom and return
    end    
    @item = Item.find(params[:id])
      
    unless params[:file_attachment][:uploaded_data] == "" then
      @file_attachment = FileAttachment.create(params[:file_attachment])
      @item.file_attachments << @file_attachment 
    end

    if @item.update_attributes(params[:item])
      flash[:notice] = 'Item was successfully updated.'
        #create event
        @project = Project.find(@bom.project_id)
        @project.create_event(Action::UPDATE_ITEM, @item, current_user)
        
        #three cases: no doc, a newly created doc, or an updated doc
        params[:itemidnum] = @item.id
        params[:projectidnum] = project.id        
        @doc_version = make_new_doc
        if @doc_version.nil? then
          redirect_to @bom  and return
        end
        unless @doc_version.new_record? then
          save_current_or_make_new(@doc_version)
        end
        @doc_version.save 
         
      redirect_to @bom  and return
    else
      render :action => "edit" 
    end

  end

  # DELETE /items/1
  def destroy
    @item = Item.find(params[:id])    
    @bom = @item.bom
    redirect_to @bom  and return
    #if current_user.is_editor?(@bom.project) then 
      #create event
      #Event.create(:user_id => current_user.id, 
        #:action => "delete item",
        #:project_id => @bom.project.id, 
        #:data => "Item [" + @item.name + "] for Project: " + @bom.project.name,
        #:body => @item.info_url,
        #:target_id => @item.id, :target_type => 'item')       
    #@item.destroy
    #end    
    redirect_to @bom  and return
  end    
  protected
  def load_item_and_bom
    session[:item] = @item
    session[:bom] = @item
  end
  
end
