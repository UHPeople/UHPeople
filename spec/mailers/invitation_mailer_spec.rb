require 'rails_helper'

RSpec.describe InvitationMailer do
  let(:user) { FactoryGirl.create(:user) }

  context 'in sent mail' do
    let(:mail) { described_class.invitation_email(user, '@helsinki.fi') }

    it 'has correct sender email' do
      expect(mail.from).to eql(['uh.people@helsinki.fi'])
    end

    it 'has correct receiver' do
      expect(mail.to).to eql('@helsinki.fi')
    end

    it 'has correct subject' do
      expect(mail.subject).to eql('Invitation to UHPeople from asd asd')
    end

    it 'has application url in body' do
      expect(mail.body.encoded).to match('https://limppu.it.helsinki.fi/')
    end
  end
end
