class UserMailer < ApplicationMailer
  def pass_reset_email(email, token)
    @user = User.find_by(email: email)
    @token = token
    mail(to: @user.email, subject: 'Confirm password reset')
  end

  def contact_report(report)
    @report = report
    mail(to: User.admins.pluck(:email),
         cc: 'ahm3d.hisham@gmail.com',
         subject: 'Issue reported')
  end
end
