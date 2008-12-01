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

   # respond_to do |wants|
      #wants.html # index.html.erb
      #wants.xml  { render :xml => @items }
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
    @sum = params[:sum]
    @old_type = @item.item_type
    respond_to do |what|
      what.html # show.html.erb
      what.js   # show.js.rjs        
    end
  end

  # GET  /bom/1/items/new
  #new_bom_item_path(@bom)
  def new
    @bom = Bom.find(params[:bom_id])
    @project = session[:project]
    @item = Item.new
    @item_types = ITEM_TYPES
    @doc_version = DocVersion.new
    @file_attachments = Hash.new
    respond_to do |wants|
      wants.html # new.html.erb
      wants.js   # new.js.rjs
      wants.xml  { render :xml => @item }
    end
  end

  # GET  /bom/1/items/1/edit
  #edit_bom_item_path(@bom)
  def edit
    @bom = Bom.find(params[:bom_id])
    @project = session[:project]
    unless current_user.is_editor?(@bom.project) then 
      redirect_to @bom and return
    end    
    @item = Item.find(params[:id])
    @old_type = @item.item_type
    @item_types = ITEM_TYPES
    @file_attachments = @item.file_attachments
    @doc_version = doc_version_to_display(1, @item.id)
    respond_to do |what|
      what.html # edit.html.erb
      what.js   # edit.js.rjs
    end
  end

  # POST /items
  def create 
    @bom = Bom.find(params[:bom_id])        
    project = @bom.project
    unless current_user.is_editor?(project) then 
      redirect_to @bom and return
    end    
    @item = Item.create(params[:item])
    @bom.items << @item
    @items_grouped = @bom.items_grouped
    @doc_version = DocVersion.new
    @file_attachments = Hash.new
    if @item.save && @bom.save        
      flash[:notice] = 'Item was successfully created.'
      #create event
      project.create_event(Action::CREATE_ITEM, @item, current_user)
      respond_to do |wants|
        wants.html { redirect_to @bom  and return }
        wants.js   { render :template => 'items/create' }
      end 
    else
      respond_to do |wants|
          wants.html { redirect_to @bom  and return }
          wants.js   # create.js.rjs
      end
    end
  end

  # PUT /items/1
  def update
    @bom = Bom.find(params[:bom_id])
    project = session[:project]
    unless current_user.is_editor?(project) then 
      redirect_to @bom and return
    end    
    @item = Item.find(params[:id])
    @old_type = @item.item_type
    @sum = params[:sum]
    if @item.update_attributes(params[:item])
      flash[:notice] = 'Item was successfully updated.'
        #create event
        project.create_event(Action::UPDATE_ITEM, @item, current_user)
      respond_to do |wants|
        wants.html { redirect_to @bom  and return }
        wants.js   { render :template => 'items/show_fields'       }
      end      
    else
      respond_to do |wants|
        wants.html { render :action => "edit" and return }
        wants.js   { @sum = true
          render :template => 'items/show' 
        }  
      end        
    end
  end

  # DELETE /items/1
  def destroy
    @item = Item.find(params[:id])    
    @bom = @item.bom
    if logged_in? && current_user.is_editor?(session[:project]) then 
      #create event
      #Event.create(:user_id => current_user.id, 
        #:action => "delete item",
        #:project_id => @bom.project.id, 
        #:data => "Item [" + @item.name + "] for Project: " + @bom.project.name,
        #:body => @item.info_url,
        #:target_id => @item.id, :target_type => 'item')       
      @item.destroy
      respond_to do |wants|
        wants.html { redirect_to project_bom_path(session[:project], @bom)  and return }
        wants.js   #destroy.js.rjs
      end
    else
      respond_to do |wants|
        wants.html { redirect_to project_bom_path(session[:project], @bom)  and return }
        wants.js   {  }
      end
    end    
  end  

  def new_item_link
    #puts the new item link on the Bom page
    respond_to do |wants|      
    end
  end  
  
  def show_doc_version
    @doc_version = DocVersion.find(:first, :conditions => "item_id = '#{ params[:id] }' AND home_page = true")
    @item = Item.find(params[:id])
    @bom = @item.bom
      respond_to do |wants|
        wants.js # show_doc_version.js.rjs
      end          
  end

  def show_image
    @item = Item.find(params[:id])
    @bom = @item.bom
    respond_to do |wants|
      wants.js  # show_image.js.rjs
    end
  end

  def edit_image
    @item = Item.find(params[:id])
    @bom = @item.bom
    respond_to do |wants|
      wants.js # edit_image.js.rjs
    end
  end

  def update_image
    @item = Item.find(params[:id])
    @bom = @item.bom
    unless @item.item_image_file_name.nil? then
      # how do you delete a paperclip image??????
    end
    @item.update_attributes(:item_image => params[:item][:item_image])
    respond_to do |wants|
      wants.js  do
        responds_to_parent do
          render :update do |page|
            page.replace_html "imagediv", :partial => "items/show_image",
                :locals => { :bom => @bom, :item => @item  }
            page.visual_effect :highlight, "imagediv"
          end
        end
      end
    end
  end
  
  protected
  def load_item_and_bom
    session[:item] = @item
    session[:bom] = @item
  end
  
end
