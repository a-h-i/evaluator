require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  let(:user) { FactoryBot.create(:student) }
  context ".pass_reset_email(email, token)" do
    let(:token) { user.gen_pass_reset_token }
    let(:mail) { UserMailer.pass_reset_email(user.email, token) }
    it "has appropriate subject" do
      expect(mail).to have_subject("Confirm password reset")
    end
    it "sends from the default email" do
      expect(mail).to be_delivered_from("no-reply@metguc.in")
    end
    it "delivers to the correct email" do
      expect(mail).to deliver_to(user.email)
    end
    it "includes confirm reset url" do
      url = "https://metguc.in/#/reset?token=#{token}"
      expect(mail).to have_body_text url
    end
  end
  context ".verification_email(email, token)" do
    before :each do
      user.verified = false
      user.save
      @token = user.gen_email_verification_token
      @mail = UserMailer.verification_email(user.email, @token)
    end
    it 'has appropriate subject' do
      expect(@mail).to have_subject("Verify Account")
    end
    it "sends from the default email" do
      expect(@mail).to be_delivered_from("no-reply@metguc.in")
    end
    it "delivers to the correct email" do
      expect(@mail).to deliver_to(user.email)
    end
    it "includes verification url" do
      url = "https://metguc.in/#/verify?token=#{@token}"
      expect(@mail).to have_body_text url
    end
  end
end
