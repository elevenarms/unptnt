class Mailer < ActionMailer::Base
  
  def invitation(recipient_email, project, sender)
    subject    "Invitation from #{ sender.name }"
    recipients recipient_email
    from       'invitations@unptnt.com'
    body       :return_url => "http://www.unptnt.com/projects/#{ project.id }",
               :project_name => project.name,
               :sender_name => sender.name
  end

end
