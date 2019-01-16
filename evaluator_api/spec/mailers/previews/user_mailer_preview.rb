# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def verification_email
    user = User.first
    user ||= FactoryGirl.create(:student)
    UserMailer.verification_email user
  end

  def pass_reset_email
    user = User.first
    user ||= FactoryGirl.create(:student)
    UserMailer.pass_reset_email user
  end
end
