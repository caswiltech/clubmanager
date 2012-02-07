class RegistrationsController < ApplicationController

  before_filter :find_club, :except => [:index]
  before_filter :form_vars, :only => [:new]

  def index
    @clubs = Club.all
  end

  def show
  
  end

  def new
    season_id = params[:season]
    season = season_id.to_i.is_a?(Numeric) ? (@club.seasons.accepting_registrations_now.where(:id => season_id.to_i).first.nil? ? nil : Season.find_by_id(@club.seasons.accepting_registrations_now.where(:id => season_id.to_i).first.id)) : nil
    if season.present?
      @registration = nil
      player_extid = params[:player]
      reg_token = params[:auth]
      # is there a player param, and does it return a valid player for this club?
      if player_extid.present? && Player.find_by_extid(player_extid).present? && reg_token.present? && RegistrationToken.find_by_token(reg_token).present? && RegistrationToken.find_by_token(reg_token).valid_for_player?(player_extid)
        
        player = Player.find_by_extid(player_extid)
        reg_token = RegistrationToken.find_by_token(reg_token)
    
        @registration = Registration.new(:club => @club, :season => season, :player => player, :registration_token_id => reg_token.id)
          RegistrationQuestionResponse.populate_responses_for_registration(@registration, true)

        prev_pg = player.registrations.last.registrations_people.parent_guardians
        
        prev_pg.each do |rp|
          @registration.registrations_people.build(:person => rp.person, :person_role => rp.person_role, :primary => rp.primary)
        end
        
        if prev_pg.count == 0
          @registration.registrations_people.build(:person => Person.new(@person_defaults), :person_role => PersonRole.find_by_role_abbreviation('PG'), :primary => true)
        end
        if prev_pg.count < 2
          @registration.registrations_people.build(:person => Person.new(@person_defaults), :person_role => PersonRole.find_by_role_abbreviation('PG'), :primary => false)                    
        end
        
      else
        @registration = Registration.new(:club => @club, :season => season, :player_attributes => {:birthdate => Date.civil(Date.today.years_ago(5).year, 1, 1), :person_attributes => @player_person_defaults})
        RegistrationQuestionResponse.populate_responses_for_registration(@registration, true)
        @registration.registrations_people.build(:person => Person.new(@person_defaults), :person_role => PersonRole.find_by_role_abbreviation('PG'), :primary => true)
        @registration.registrations_people.build(:person => Person.new(@person_defaults), :person_role => PersonRole.find_by_role_abbreviation('PG'), :primary => false)
      end
    else
      redirect_to club_url(@club.subdomain)
    end
  end

  def create    
    reg_params = params[:registration]

    # clean out parent/guardian 2 if they are empty
    if reg_params[:registrations_people_attributes]["1"].present? && reg_params[:registrations_people_attributes]["1"][:person_attributes][:first_name].blank? && reg_params[:registrations_people_attributes]["1"][:person_attributes][:last_name].blank?
      reg_params[:registrations_people_attributes].delete("1")
    end
        
    if reg_params[:player_attributes][:id].blank?
      @registration = @club.registrations.new(reg_params)
    else
      # returning player reg, so we need to manually create the
      #   registrations_person records because of weak-ass rails
      #   nested attribute handling. Bah humbug!
      primary_guardian_person_id = reg_params[:registrations_people_attributes]["0"][:person_attributes][:id]
      secondary_guardian_person_id = reg_params[:registrations_people_attributes]["1"][:person_attributes][:id] if reg_params[:registrations_people_attributes]["1"].present?
      
      registrations_people = []
      primary_guardina = nil
      secondary_guardian = nil
      if primary_guardian_person_id.present?
        primary_guardian = RegistrationsPerson.new(:person_id => primary_guardian_person_id, :person_role => PersonRole.find_by_role_abbreviation('PG'), :primary => true)
        primary_guardian.attributes = reg_params[:registrations_people_attributes]["0"]
      else
        primary_guardian = RegistrationsPerson.new(reg_params[:registrations_people_attributes]["0"])
      end
      registrations_people << primary_guardian
      if reg_params[:registrations_people_attributes]["1"].present?
        if secondary_guardian_person_id.present?
          secondary_guardian = RegistrationsPerson.new(:person_id => secondary_guardian_person_id, :person_role => PersonRole.find_by_role_abbreviation('PG'), :primary => false)
          secondary_guardian.attributes = reg_params[:registrations_people_attributes]["1"]
        else
          secondary_guardian = RegistrationsPerson.new(reg_params[:registrations_people_attributes]["1"])
        end        
        registrations_people << secondary_guardian
      end
      reg_params.delete(:registrations_people_attributes)
            
      @registration = @club.registrations.new(:player_id => reg_params[:player_attributes][:id].to_i, :registrations_people => registrations_people)      
      @registration.attributes = reg_params
    end
    
    season = @club.seasons.accepting_registrations_now.where(:id => @registration.season_id).first
    unless season.present?
      redirect_to club_url(@club.subdomain)
    else
      division = Division.for_season_and_birthdate(@registration.season, @registration.player.birthdate)
      unless division.present?
        if @registration.registrations_people.size < 2
          @registration.registrations_people.build(:person => Person.new(@person_defaults), :person_role => PersonRole.find_by_role_abbreviation('PG'), :primary => false)
        end
        form_vars
        @message = "Unfortunately no team was found matching this player's age for the desired season. If necessary, please correct the player's birthdate."
        flash.now[:error] = @message
        render :action => "new"
      else
        @registration.division = division
        sd = SeasonDivision.find_by_season_id_and_division_id(season.id, division.id)
        @registration.team = sd.teams.first unless sd.nil?
        layer = Layers::PublicRegistration.new(@registration)
        unless layer.save
          Rails::logger.info "Errors: #{@registration.errors.ai}\n\n"
          form_vars
          @message = "Unfortunately some errors occurred. Please see the form below, correct the errors and re-submit the information."
          flash.now[:error] = @message
          render :action => "new"      
        else
          # don't want someone to try and hack this registration into a different club, now do we!
          @registration.update_attribute(:club_id, @club.id)
          @pp = PaymentPackage.for_season_and_division(@registration.season, @registration.division)
          RegistrationQuestionResponse.populate_responses_for_registration(@registration, false)
          RegistrationQuestionResponse.create_default_responses_for_protected_questions(@registration)
          render :action => :step2
        end
      end
    end
  end

  def finalize
    reg_params = params[:registration]
    @registration = @club.registrations.find_by_id(reg_params[:id])
    @pp = PaymentPackage.for_season_and_division(@registration.season, @registration.division)
    if @registration.update_attributes(reg_params)
      begin
        RegistrationMailer.deliver_public_registration(@registration)
        RegistrationMailer.deliver_club_reg_notification(@registration)
      rescue
        # not going to do anything right now - we'll just log errors
        Rails::logger.info "\n\n#{'x'*50}\n\n"
        Rails::logger.info "looks like there was an error with the mailer\n\n"
        
      end
      @payment_method = @registration.payment_option.name
      render :action => :finalize
    else
      Rails::logger.info "Errors: #{@registration.errors.ai}\n\n"
      render :action => :step2
    end
  end
  
  def regreport
    # @registrations = @club.registrations.thisyear.order("id desc")
    season_id = params[:season]
    if season_id.present?
      @registrations = @club.registrations.where(:season_id => season_id).order("id desc")
    else
      @registrations = @club.registrations.order("id desc")
    end
  end
  
  def delete_reg
    reg_id = params[:reg]
    reg = @club.registrations.find(reg_id)

    reg.registrations_people.each do |p|
      unless p.person.registrations_people.count > 1
        p.person.destroy
      end
      p.destroy
    end
    unless reg.player.registrations.count > 1
      reg.player.person.destroy
      reg.player.destroy
    end
    reg.destroy
    
    redirect_to regreport_url(@club.subdomain)
  end
  
  def regreport_csv
    season_id = params[:season]
    if season_id.present?
      @csv_registrations = @club.registrations.where(:season_id => season_id).order("id desc")
    else
      @csv_registrations = @club.registrations.order("id asc")
    end
    render_csv("#{@club.subdomain}-regreport-#{Time.now.strftime("%Y%m%d")}")
  end
  
  def mail_list
    @registrations = @club.registrations.thisyear.where("division_id = ?", params[:division].to_i)
  end
  
  def tax_receipt
    reg_id = params[:reg]
    @registration = @club.registrations.find(reg_id)
    
    respond_to do |format|
      format.html { render :layout => false  }
      format.pdf { render(:pdf => "tax_receipt", :layout => false) }
    end
  end

  def tax_receipts
    season_id = params[:season]
    season = @club.seasons.find(season_id)
    @count = [0,0,0]
    @count[0] = season.registrations.count
    @count[1] = season.registrations.receipt_eligible.count
    
    season.registrations.receipt_eligible.each do |r|
      if r.registrations_people.parent_guardians.present?
        @registration = r
        receipt_file = render_to_string :pdf => "tax_receipt",
                                  :template => 'registrations/tax_receipt',
                                  :layout => false,
                                  :page_size => 'Letter'

        begin
          RegistrationMailer.deliver_taxreceipt(@registration, receipt_file)
        rescue
          # not going to do anything right now - we'll just log errors
          Rails::logger.info "\n\n#{'x'*50}\n\n"
          Rails::logger.info "looks like there was an error with the mailer\n\n"
        end
        @count[2] += 1
      end
    end
  end

  private

  def find_club
    club_id = params[:club_id]
    @club ||= club_id.nil? ? nil : (Club.where(:subdomain => club_id).present? ? Club.where(:subdomain => club_id).first : (Club.where(:id => club_id).present? ? Club.where(:id => club_id).first : nil))
  end

  def form_vars
    @cities = ["Anmore","Burnaby","Coquitlam","Delta","Langley","Maple Ridge","New Westminster","North Vancouver","Pitt Meadows","Port Coquitlam","Port Moody","Richmond","Surrey","Vancouver","West Vancouver","White Rock","Other"]
    @provinces = %w{ BC AB SK MB ON QC NB PE NS NF YK NW NV }
    @person_defaults = {:city => @club.city, :province => @club.province, :country => @club.country}
    @player_person_defaults = @person_defaults.merge({:phone_type => "Home"})
  
    @phone_types = ["Home", "Work", "Cell", "Other"]
    @email_types = ["Home", "Work", "Personal", "Other"]
  end

end