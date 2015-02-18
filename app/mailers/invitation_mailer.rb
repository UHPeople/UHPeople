class InvitationMailer < ApplicationMailer

  def invitation_email(user, receiver)
    @user = user
    @url  = 'http://uhpeople.herokuapp.com/'
    email_with_name = %("#{@user.name}" <#{@user.email}>)
    mail(from: email_with_name,
         to: receiver,
         subject: 'Welcome to UHPeople'
    )
  end

end
