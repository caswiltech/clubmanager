class RegistrationMailer < ActionMailer::Base
  default :from => "from@example.com"
  
  def public_registration(registration)
    @registration = registration
    mail_to = []
    mail_to << "#{registration.parent_guardian1.first_name} #{registration.parent_guardian1.last_name} <#{registration.parent_guardian1.email}>" unless registration.parent_guardian1.email.nil?
    mail_to << "#{registration.parent_guardian2.first_name} #{registration.parent_guardian2.last_name} <#{registration.parent_guardian2.email}>" unless registration.parent_guardian2.email.nil?
    if mail_to.empty?
      mail_to << "#{registration.club.reg_notify_email}"
    end
    mail_from = "#{registration.club.reg_notify_email}"
    mail_bcc = mail_from
    mail_subject = "#{registration.club.short_name} #{registration.season.name} Registration for #{registration.player.person.first_name} #{registration.player.person.last_name}"
    mail_sent_on = Time.now
    mail(
      :to => mail_to,
      :bcc => mail_bcc,
      :from => mail_from,
      :subject => mail_subject,
      :sent_on => mail_sent_on,
    )
  end
end
