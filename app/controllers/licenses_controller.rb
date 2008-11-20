class LicensesController < ApplicationController
  
  before_filter :login_required, :only => [ :new, :edit, :create, :update, :destroy ]
  
  def index
    @licenses = License.find(:all)
  end

  def show
    @license = License.find(params[:id])
  end

  def new
    @license = License.new
  end

  def edit
    @license = License.find(params[:id])
  end

  def create
    @license = License.create(params[:license])

      if @license.save
        flash[:notice] = 'License was successfully created.'
        redirect_to :action => "index"
      else
        render :action => "new" 
      end
  end

  def update
    @license = License.find(params[:id])

      if @license.update_attributes(params[:license])
        flash[:notice] = 'License was successfully updated.'
        redirect_to :action => "index"
      else
        render :action => "new" 
      end    
  end

  def destroy
  end

end
