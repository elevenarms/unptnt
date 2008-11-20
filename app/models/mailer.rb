class Mailer < ActionMailer::Base
  
  def invitation(invitation, signup_url, sender_name)
    subject    'Invitation'
    recipients invitation.recipient_email
    from       'invitations@unptnt.com'
    body       :invitation => invitation, :signup_url => signup_url, :sender_name => sender_name
    invitation.update_attribute(:sent_at, Time.now)
  end

end
