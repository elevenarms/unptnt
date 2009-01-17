class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  layout 'application'
  before_filter :login_required, :except => [:index, :new, :create]

  def index
    @users = User.find(:all)
  end

  def show
    @user = User.find(params[:id])
    if @user.nil? then
      redirect_to projects_path and return
    end
    @related_projects = @user.related_projects
    @doc_versions = @user.doc_versions
    @uploaded_image = UploadedImage.fetch_single_image_for("user", @user.id, "home_page")
    @current_user_is_editor = logged_in? ? current_user.id == @user.id : false
    @current_user_id = logged_in? ? current_user.id : "0"
  end

  # render new.rhtml 
  def new
    @user = User.new
end
 
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    success = @user && @user.save
    if success && @user.errors.empty?
      redirect_back_or_default('/')
      add_message("Thanks for signing up!  We're sending you an email with your activation code.")
    else
      add_error("We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above).")
      render :action => 'new'
    end
  end

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      add_message("Signup complete! Please sign in to continue.")
      redirect_to '/login'
    when params[:activation_code].blank?
      add_error("The activation code was missing.  Please follow the URL from your email.")
      redirect_back_or_default('/')
    else 
      add_error("We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in.")
      redirect_back_or_default('/')
    end
  end
  
  def edit
    @user = User.find(params[:id])
    if @user.nil? then 
      redirect_to projects_path and return
    end    
    redirect_to projects_path unless logged_in?
    redirect_to projects_path unless @user.id == current_user.id
    @uploaded_image = UploadedImage.fetch_single_image_for("user", @user.id, "home_page")
    @current_user_is_editor = logged_in? ? current_user.id == @user.id : false
    @current_user_id = logged_in? ? current_user.id : "0"
  end
  
  def update
    @user = User.find(params[:id])
    if @user.nil? then 
      redirect_to projects_path and return
    end    
    redirect_to projects_path unless logged_in?
    redirect_to projects_path unless @user.id == current_user.id    

    if @user.update_attributes(params[:user])
      add_message('User profile was successfully updated.')
      redirect_to(dashboard_path)
    else
      redirect_to edit_user_path(@user)
    end   
  end
end
