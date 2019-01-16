class UserMailer < ApplicationMailer

  def pass_reset_email(user)
    @user = user
    @token = @user.gen_reset_token
    mail(to: @user.email, subject: 'Confirm password reset')
  end

  def verification_email(user)
    @user = user
    @token = @user.gen_verification_token
    mail(to: @user.email, subject: 'Verify your account')
  end

  def project_bundle(user, bundle)
    @user = user
    @bundle = bundle
    mail(to: @user.email, subject: 'Project bundle download link')
  end

  def contact_report(report)
    @report = report
    mail(to: User.admins.pluck(:email),
         cc: 'ahm3d.hisham@gmail.com',
         subject: 'Issue reported')
  end
end
