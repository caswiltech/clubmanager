class RegistrationMailer < ActionMailer::Base
  default :from => "info@hyackfootball.com"
  
  def public_registration(registration)
    @registration = registration
    mail_to = []
    mail_to << "#{registration.parent_guardian1.first_name} #{registration.parent_guardian1.last_name} <#{registration.parent_guardian1.email} ERROR!>" unless registration.parent_guardian1.email.blank?
    mail_to << "#{registration.parent_guardian2.first_name} #{registration.parent_guardian2.last_name} <#{registration.parent_guardian2.email}>" unless registration.parent_guardian2.nil? || registration.parent_guardian2.email.blank? || registration.parent_guardian2.email == registration.parent_guardian1.email
    if mail_to.blank?
      mail_to << "EMAIL NOT PROVIDED <#{registration.club.reg_notify_email}>"
    end
    mail_from = "#{registration.club.reg_notify_email}"
    mail_bcc = mail_from
    mail_subject = "#{registration.club.short_name} #{registration.season.name} Registration for #{registration.player.person.first_name} #{registration.player.person.last_name}"
    mail(
      :to => mail_to,
      :bcc => mail_bcc,
      :from => mail_from,
      :subject => mail_subject
    )
  end
end
