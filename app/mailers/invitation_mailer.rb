class InvitationMailer < ApplicationMailer
default from: 'uhpeople@gmail.com'
  def invitation_email(user, receiver)
    @user = user
    @url  = "https://limppu.it.helsinki.fi/"
    mail(to: receiver,
         subject: "Invitation to UHPeople from #{@user.name}"
    )
  end

end
