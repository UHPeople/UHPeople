class InvitationMailer < ApplicationMailer
default from: 'uhpeople@gmail.com'
  def invitation_email(user, receiver)
    #@receiver = receiver
    @user = user
    @url  = 'http://uhpeople.herokuapp.com/'
    #email_with_name = %("#{@user.name}" <#{@user.email}>)
    mail(#from: email_with_name,
         to: receiver,
         subject: "Invitation to UHPeople from #{@user.name}"
    )
  end

end
