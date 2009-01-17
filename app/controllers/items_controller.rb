class ItemsController < ApplicationController
  layout 'project'
  include ProjectModule
  include DocVersioning
  before_filter :login_required, :only => [ :new, :edit, :create, :update, :destroy ]
  tab :materials
  ITEM_TYPES = ["Hardware", "Software", "Tools"]
 
  # GET /bom/1/items/1
  # bom_item_path (@bom, @item)
  def show
    tab :materials
    @bom = Bom.find(params[:bom_id])
    @project = current_project(@bom.project_id)
    @item = Item.find(params[:id])
    @file_attachments = @item.file_attachments
    @count = FileAttachment.count :conditions => "item_id = '#{ @item.id }'"
    @doc_version = doc_version_to_display(1, @item.id)
    @sum = params[:sum]
    @old_type = @item.item_type
    @forum = @item.forum
    @forum = "0" if @forum.nil?
    @current_user_is_editor = logged_in? ? current_user.is_editor?(@project) : false
    @current_user_id = logged_in? ? current_user.id : "0"
    @uploaded_image = UploadedImage.fetch_single_image_for("item", @item.id, "home_page")
    respond_to do |what|
      what.html # show.html.erb
      what.js   # show.js.rjs        
    end
  end

  def show_choice
    @bom = Bom.find(params[:bom_id])
    @item = Item.find(params[:id])
    @file_attachments = @item.file_attachments
    project = current_project(@bom.project)
    @current_user_is_editor = logged_in? ? current_user.is_editor?(project) : false
    @count = FileAttachment.count :conditions => "item_id = '#{ @item.id }'"
    respond_to do |wants|
      wants.js #show_choice.js.rjs
    end
  end

  # GET  /bom/1/items/new
  #new_bom_item_path(@bom)
  def new
    @bom = Bom.find(params[:bom_id])
    @project = current_project(@bom.project_id)
    @item = Item.new
    @item_types = ITEM_TYPES
    respond_to do |wants|
      wants.html # new.html.erb
      wants.js   # new.js.rjs
      wants.xml  { render :xml => @item }
    end
  end

  def new_attachment
    @bom = Bom.find(params[:bom_id])
    @project = current_project(@bom.project_id)
    @item = Item.find(params[:id])
    @file_attachment = FileAttachment.new
  end

  # GET  /bom/1/items/1/edit
  #edit_bom_item_path(@bom)
  def edit
    @bom = Bom.find(params[:bom_id])
    @project = current_project(@bom.project_id)
    unless current_user.is_editor?(@project) then
      redirect_to @bom and return
    end
    @item = Item.find(params[:id])
    @old_type = @item.item_type
    @item_types = ITEM_TYPES
    respond_to do |wants|
      wants.html # edit.html.erb
      wants.js   # edit.js.rjs
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
    if @item.save && @bom.save
      add_message('Item was successfully created.')
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

  def create_attachment
    @bom = Bom.find(params[:bom_id])
    @project = current_project(@bom.project_id)
    unless current_user.is_editor?(project) then
      redirect_to @bom and return
    end
    @item = Item.find(params[:id])
    @current_user_is_editor = true
    unless params[:file_attachment][:uploaded_data] == "" then
      @file_attachment = FileAttachment.create(params[:file_attachment])
      @file_attachment.save
      @item.file_attachments << @file_attachment
      @file_attachments = @item.file_attachments
    respond_to do |wants|
      wants.js  do
        responds_to_parent do
          render :update do |page|
            page.insert_html(:bottom, "attachment-list", :partial => 'attachments/show',
                  :locals => { :item => @item, :bom => @bom, :file_attachment => @file_attachment,
                  :current_user_is_editor => @current_user_is_editor }   )
            page.replace_html("add-attachment", :partial => 'attachments/upload',
                  :locals => { :item => @item, :bom => @bom }   )
            page.visual_effect :highlight, "item-attachments", :duration => 1
          end
        end
      end
    end


    else
      redirect_to [@bom, @item]
    end

  end

  # PUT /items/1
  def update
    @bom = Bom.find(params[:bom_id])
    project = current_project(@bom.project.id)
    unless current_user.is_editor?(project) then
      redirect_to @bom and return
    end
    @item = Item.find(params[:id])
    @old_type = @item.item_type
    @sum = params[:sum]

    @current_user_is_editor = true
    if @item.update_attributes(params[:item])
      add_message('Item was successfully updated.')
      #create event
      project.create_event(Action::UPDATE_ITEM, @item, current_user)
      respond_to do |wants|
        wants.html { redirect_to @bom  and return }
        wants.js   { render :template => 'items/show'       }
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
    if logged_in? && current_user.is_editor?(current_project(@bom.project_id)) then
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

  def delete_attachment
    @file_attachment_id = params[:attachment_id]
    file_attachment = FileAttachment.find(@file_attachment_id)
    @item = Item.find(file_attachment.item_id)
    @bom = Bom.find(@item.bom_id)
    project = current_project(@bom.project_id)
    #@current_user_is_editor = logged_in? ? current_user.is_editor?(project) : false
    @current_user_is_editor = true
    @count = FileAttachment.count :conditions => "item_id = '#{ file_attachment.item_id }'"
    @count -= 1
    file_attachment.destroy unless file_attachment.nil?
    respond_to do |wants|
      wants.js # delete_attachment.js.rjs
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
    @project = @bom.project
    @current_user_is_editor = logged_in? ? current_user.is_editor?(@project) : false
    respond_to do |wants|
      wants.js # show_doc_version.js.rjs
    end
  end

  def show_image
    @item = Item.find(params[:id])
    @bom = @item.bom
    @project = current_project(@bom.project_id)
    @current_user_is_editor = logged_in? ? current_user.is_editor?(@project) : false
    respond_to do |wants|
      wants.js  # show_image.js.rjs
    end
  end

  def cancel_edit_image
    @item = Item.find(params[:id])
    @bom = @item.bom
    respond_to do |wants|
      wants.js  #cancel_edit_image.js.rjs
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
            page.replace_html "image-image", :partial => "items/show_image_image",
              :locals => { :bom => @bom, :item => @item  }
            page.replace_html "image-edit", :partial => "items/show_image_edit",
              :locals => { :bom => @bom, :item => @item  }
            page.visual_effect :highlight, "imagediv"
          end
        end
      end
    end
  end
end
