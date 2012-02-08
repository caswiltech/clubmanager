class RegistrationMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  
  default :from => "info@hyackfootball.com"
  
  def public_registration(registration)
    @registration = registration
    mail_to = []
    addresses = []
    registration.registrations_people.parent_guardians.each do |rp|
      unless rp.person.email.blank? || addresses.include?(rp.person.email)
        mail_to << "#{rp.person.first_name} #{rp.person.last_name} <#{rp.person.email}>"
        addresses << rp.person.email unless rp.person.email.blank?
      end
    end
    
    mail_subject = ""
    if mail_to.blank?
      mail_to << "EMAIL NOT PROVIDED <#{registration.club.reg_notify_email}>"
      mail_subject << "EMAIL NOT PROVIDED "
    end
    mail_from = "#{registration.club.reg_notify_email}"
    mail_subject << "#{registration.club.short_name} #{registration.division.name} Registration for #{registration.player.person.first_name} #{registration.player.person.last_name}"
    mail(
      :to => mail_to,
      :from => mail_from,
      :subject => mail_subject
    )
  end
  
  def club_reg_notification(registration)
    @registration = registration
    mail_to = "#{registration.club.reg_notify_email}"
    mail_from = mail_to
    mail_subject = "#{registration.division.name} Registration:  #{registration.player.person.first_name} #{registration.player.person.last_name}"    
    mail(
      :to => mail_to,
      :from => mail_from,
      :subject => mail_subject
    )
  end
  
  def taxreceipt(registration, receipt_file)
    @registration = registration

    mail_to = ""
    rp = registration.registrations_people.parent_guardians.first
    if rp.present? && rp.person.present?
      unless rp.person.email.blank? && mail_to.blank?
        mail_to = "#{rp.person.first_name} #{rp.person.last_name} <#{rp.person.email}>"
      end
    end
    
    mail_subject = ""
    if mail_to.blank?
      mail_to = "EMAIL NOT PROVIDED <#{registration.club.reg_notify_email}>"
      mail_subject << "EMAIL NOT PROVIDED "
    end
    
    mail_from = "#{registration.club.short_name} <#{registration.club.reg_notify_email}>"
    mail_subject << "#{registration.season.name} Tax Receipt for #{registration.player.legal_name}"
    attachments["rchfc_taxreceipt_2011.pdf"] = receipt_file
    mail(
      :to => mail_to,
      # :bcc => mail_bcc,
      :from => mail_from,
      :subject => mail_subject
    )
  end
  
  def rereg(person, options = {})
    email = options[:email].present? ? options[:email] : nil
    @bulk = options[:bulk].present? ? options[:bulk] : nil
    @auth_token = RegistrationToken.create(:club => person.club, :person => person).token
    @club = person.club    
    
    mail_to = []
    if email.present? && (person.email == email || person.alt_email == email)
      mail_to << "#{person.first_name} #{person.last_name} <#{email}>"
    else
      mail_to << "#{person.first_name} #{person.last_name} <#{person.email}>" unless person.email.blank?
      mail_to << "#{person.first_name} #{person.last_name} <#{person.alt_email}>" unless person.alt_email.blank? || person.alt_email == person.email
    end
    mail_from = "#{person.club.short_name} <#{person.club.reg_notify_email}>"
    mail_subject = "#{person.club.short_name} Re-Registration Link"
    
    mail(
      :to => mail_to,
      :from => mail_from,
      :subject => mail_subject
    )
  end

end
