class InvitationsController < ApplicationController

  def create
    @project = current_project(params[:project_id])
    @recipient_email = (params[:recipient_email])
    if logged_in?
      Mailer.deliver_invitation(@recipient_email, @project, current_user)
      add_message("Thank you, invitation sent.")
      redirect_to dashboard_path and return
    else
      add_message("Thank you, we will notify when we are ready to accept new users.")
      redirect_to projects_path and return
    end
  end
  
end
