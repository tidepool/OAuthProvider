require 'spec_helper'

describe MailSender do

  let(:user1) { create(:user) }

  it 'prepares the mail to send' do 
    mail_sender = MailSender.new
    is_sent = mail_sender.perform(:UserMailer, :welcome_email, {user_id: user1.id})
    is_sent.should be_true
  end
end