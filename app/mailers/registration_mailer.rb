class RegistrationMailer < ActionMailer::Base
  default :from => "info@hyackfootball.com"
  
  def public_registration(registration)
    @registration = registration
    mail_to = []
    addresses = []
    @registration.registrations_people.parent_guardians.each do |rp|
      unless rp.person.email.blank? || addresses.include?(rp.person.email)
        mail_to << "#{rp.person.first_name} #{rp.person.last_name} <#{rp.person.email}>"
        addresses << rp.person.email unless rp.person.email.blank?
      end
    end
    if mail_to.blank?
      mail_to << "EMAIL NOT PROVIDED <#{registration.club.reg_notify_email}>"
    end
    mail_from = "#{registration.club.reg_notify_email}"
    mail_bcc = mail_from
    mail_subject = "#{registration.club.short_name} #{registration.division.name} Registration for #{registration.player.person.first_name} #{registration.player.person.last_name}"
    mail(
      :to => mail_to,
      :bcc => mail_bcc,
      :from => mail_from,
      :subject => mail_subject
    )
  end
end
