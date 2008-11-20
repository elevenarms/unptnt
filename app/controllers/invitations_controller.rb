class InvitationsController < ApplicationController
  
  def new
    @invitation = Invitation.new
  end

  def create
    @invitation = Invitation.new(params[:invitation])
    @invitation.sender = current_user
    if @invitation.save
      if logged_in?
        Mailer.deliver_invitation(@invitation, signup_url(@invitation.token), current_user.name)
        flash[:notice] = "Thank you, invitation sent."
        redirect_to dashboard_path
      else
        flash[:notice] = "Thank you, we will notify when we are ready to accept new users."
        redirect_to projects_path
      end
    else
      render :action => 'new'
    end
  end
  
end
