class InviteController < ApplicationController
  def index
  end

  def send_email
    @user = current_user
    @receiver = params[:receiver]
    # tarkista että receiver loppuu @helsinki.fi
    if @receiver.include? '@helsinki.fi'
      if InvitationMailer.invitation_email(@user, @receiver).deliver_now
        redirect_to :root, notice: 'Invitation was sent succesfully.'
      else
        redirect_to :back, notice: 'Error sending invitation.'
      end
    else
      redirect_to :back, notice: 'Recipient must be a "@helsinki.fi" email address.'
    end
  end
end
