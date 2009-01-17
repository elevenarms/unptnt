class UploadedImagesController < ApplicationController

    # show all images for a given image_type and id
  def index

  end

  #show a single, home_page image for user, project, or item
  #when called wanting HTML, shows image and choice
  #when called wanting JS, shows choice
  def show
    p = params[:uploaded_image]
    unless p.has_key?("project_id") && p.has_key?("item_id") && p.has_key?("user_id") && p.has_key?("image_type") && p.has_key?("purpose")
      add_error("Cannot find image with given attributes")
      return
    end
    which_key = p[:project_type] + "_id"
    @image = UploadedImage.fetch_single_image_for(p[:project_type], p[which_key], p[:purpose])
    respond_to do |wants|
      wants.js do
        respond_to :update do
          page.replace_html("image-image", :partial => 'uploaded_images/show_image',
                  :locals => { :image => @image }   )
          page.visual_effect :highlight, "image-image", :duration => 1
        end
      end
      wants.html #show.html.erb
    end
  end

  #show the user the image upload form
  def new
    unless params.has_key?("project_id") && params.has_key?("item_id") && params.has_key?("user_id") && params.has_key?("image_type") && params.has_key?("purpose") then
      add_error("Cannot find image with given attributes")
      #return
    end
    @image = UploadedImage.new
    @parameters = params
    respond_to do |wants|
      wants.js # new.js.rjs
    end

  end

  # upload a new image using hidden field parameters
  def create
    @parameters = params[:uploaded_image]
    unless @parameters.has_key?("project_id") && @parameters.has_key?("item_id") && @parameters.has_key?("user_id") && @parameters.has_key?("image_type") && @parameters.has_key?("purpose") then
      add_error("Cannot find image with given attributes") and return
    end
    if @parameters[:purpose] == "home_page"  then
      case @parameters[:image_type]
      when "user" then
        owner_id = @parameters[:user_id]
      when  "project" then
        owner_id = @parameters[:project_id]
      when "item" then
        owner_id = @parameters[:item_id]
      end
    previous_image = UploadedImage.fetch_single_image_for(@parameters[:image_type],
          owner_id, @parameters[:purpose])
    end
    @uploaded_image = UploadedImage.new(@parameters)
    valid = @uploaded_image.valid?
    add_error("Could not upload image") and return unless @uploaded_image.save
    current_user.uploaded_images << @uploaded_image if logged_in?
    unless @parameters[:project_id] == "0"
      project = current_project(@parameters[:project_id])
      project.uploaded_images << @uploaded_image
    end
    unless @parameters[:item_id] == '0'
      item = Item.find(@parameters[:item_id])
      item.uploaded_images << @uploaded_image 
    end
    #delete the previous image of this purpose if there was one
    result = UploadedImage.destroy(previous_image.id)  unless  previous_image.nil?
    if @parameters[:image_type] == "user" then
      a = current_user.id
      b = current_user[:id]
      c = @parameters[:user_id]
      d = logged_in?
      @current_user_is_editor = logged_in? ? (current_user.id.to_s == @parameters[:user_id]) : false
    else
      @current_user_is_editor = logged_in? ? current_user.is_editor?(project) : false
    end
    respond_to do |wants|
      wants.html { redirect_to @bom  and return }
      wants.js   do
        responds_to_parent do
          render :update do |page|
            page.replace_html "image-image", :partial => 'uploaded_images/show',
              :locals => { :uploaded_image => @uploaded_image }
            page.replace_html("replace-image", :partial => 'uploaded_images/show_choice',
                :locals => { :project_id => @parameters[:project_id], :user_id => @parameters[:user_id],
                :item_id => @parameters[:item_id], :image_type => @parameters[:image_type],
                :purpose => @parameters[:purpose], :current_user_is_editor => @current_user_is_editor} )
            page.visual_effect :highlight, "imagediv", :duration => 1
          end
        end
      end
    end
  end

  #delete an image
  def destroy

  end

  def show_choice
    @parameters = params
    unless @parameters.has_key?("project_id") && @parameters.has_key?("item_id") && @parameters.has_key?("user_id") && @parameters.has_key?("image_type") && @parameters.has_key?("purpose") then
      add_error("Cannot find image with given attributes") and return
    end
    @current_user_is_editor = logged_in? ? current_user.is_editor?(current_project(@parameters[:project_id])) : false
    respond_to do |wants|
      wants.js #show_choic.js.rjs
    end
  end
end
