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
      @registration = Registration.new(:club => @club, :season => season, :player_attributes => {:birthdate => Date.civil(Date.today.years_ago(5).year, 1, 1), :person_attributes => @player_person_defaults})
      RegistrationQuestionResponse.populate_responses_for_registration(@registration, true)
      @registration.registrations_people.build(:person => Person.new(@person_defaults), :person_role => PersonRole.find_by_role_abbreviation('PG'), :primary => true)
      @registration.registrations_people.build(:person => Person.new(@person_defaults), :person_role => PersonRole.find_by_role_abbreviation('PG'), :primary => false)
    else
      redirect_to club_url(@club.subdomain)
    end
  end

  def create    
    reg_params = params[:registration]
    
    # clean out parent/guardian 2 if they are empty
    if reg_params[:registrations_people_attributes]["1"][:first_name].blank? && reg_params[:registrations_people_attributes]["1"][:last_name].blank?
      reg_params[:registrations_people_attributes].delete("1")
    end
      
    @registration = @club.registrations.new(reg_params)
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
      rescue
        # not going to do anything right now - we'll just log errors
        Rails::logger.info "\n\n#{'x'*50}\n\n"
        Rails::logger.info "looks like there was an error with the mailer\n\n"
        
      end
      @payment_method = @registration.registration_question_responses.where(:registration_question_id => @registration.registration_questions.where(:report_label => "Payment Method").first.id).last.registration_question_response_option.response_value
      render :action => :finalize
    else
      Rails::logger.info "Errors: #{@registration.errors.ai}\n\n"
      render :action => :step2
    end
  end
  
  def regreport
    @registrations = @club.registrations.order("id desc")
  end
  
  def delete_reg
    reg_id = params[:reg]
    reg = @club.registrations.find(reg_id)

    reg.registrations_people.each do |p|
      p.person.destroy
      p.destroy
    end
    reg.player.person.destroy
    reg.player.destroy
    reg.destroy
    
    redirect_to regreport_url(@club.subdomain)
  end
  
  def regreport_csv
    @csv_registrations = @club.registrations.order("id asc")
    render_csv("#{@club.subdomain}-regreport-#{Time.now.strftime("%Y%m%d")}")
  end
  
  def mail_list
    @registrations = @club.registrations.where("division_id = ?", params[:division].to_i)
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