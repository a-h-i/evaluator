require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  let(:user) { FactoryGirl.create(:teacher) }
  context '.pass_reset_email(user)' do
    let(:mail) { UserMailer.pass_reset_email(user) }
    before(:each) do
      mail.deliver_now!
    end
    it 'has appropriate subject' do
      expect(mail).to have_subject('[EVALUATOR] Confirm password reset')
    end
    it 'sends from the default email' do
      expect(mail).to be_delivered_from('evaluator@evaluator.in')
    end
    it 'delivers to the correct email' do
      expect(mail).to deliver_to(user.email)
    end
    it 'includes confirm reset url' do
      url = 'http://evaluator.in/#/reset/' + "#{user.id}?token=#{user.gen_reset_token}"
      expect(mail.text_part).to have_body_text url
    end
  end
  context '.verification_email(user)' do
    let(:mail) { UserMailer.verification_email(user) }
    before(:each) do
      mail.deliver_now!
    end
    it 'has appropriate subject' do
      expect(mail).to have_subject('[EVALUATOR] Verify your account')
    end
    it 'sends from the default email' do
      expect(mail).to be_delivered_from('evaluator@evaluator.in')
    end
    it 'delivers to the correct email' do
      expect(mail).to deliver_to(user.email)
    end
    it 'includes verification url' do
      url = 'http://evaluator.in/#/verify/' + "#{user.id}?token=#{user.gen_verification_token}"
      expect(mail).to have_body_text url
      expect(mail.text_part).to have_body_text url
    end
  end
  context '.contact_report' do
    let(:report) { FactoryGirl.create(:contact) }
    let(:mail) {UserMailer.contact_report(report)}
    before(:each) do
      mail.deliver_now!
    end

    it 'has appropriate subject' do
      expect(mail).to have_subject('[EVALUATOR] Issue reported')
    end

    it 'sends from the default email' do
      expect(mail).to be_delivered_from('evaluator@evaluator.in')
    end

  end
end
