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
      @registration = Registration.new(:club => @club, :season => season, :payment_method => 'Cheque', :player_attributes => {:birthdate => Date.civil(Date.today.years_ago(5).year, 1, 1), :person_attributes => @player_person_defaults}, :registrations_people_attributes => [{:person_attributes => @person_defaults, :person_role => PersonRole.find_by_role_abbreviation('PG'), :primary => true},{:person_attributes => @person_defaults, :person_role => PersonRole.find_by_role_abbreviation('PG'), :primary => false}]
      )
    else
      redirect_to club_url(@club.subdomain)
    end
  end

  def create    
    reg_params = params[:registration]
    
    # clean out parent/guardian 2 if they are empty
    if reg_params[:registrations_people_attributes]["1"][:first_name].blank? && reg_params[:registrations_people_attributes]["1"][:last_name].blank?
      
      Rails::logger.info "\n\n#{'x'*50}\n\n"
      Rails::logger.info "pg2 first name is blank\n\n"
      reg_params[:registrations_people_attributes].delete("1")
    end
      
      
    
    @registration = @club.registrations.new(reg_params)
    season = @club.seasons.accepting_registrations_now.where(:id => @registration.season_id).first
    unless season.present?
      redirect_to club_url(@club.subdomain)
    else
      division = Division.for_season_and_birthdate(@registration.season, @registration.player.birthdate)
      unless division.present?
        # if @registration.
        @registration.parent_guardian2 = Person.new(reg_params[:parent_guardian2_attributes])
        form_vars
        @message = "Unfortunately no team was found matching this player's age for the desired season. If necessary, please correct the player's birthdate."
        flash.now[:error] = @message
        render :action => "new"
      else
        @registration.division = division
        layer = Layers::PublicRegistration.new(@registration)
        unless layer.save
          Rails::logger.info "Errors: #{@registration.errors.ai}\n\n"
          form_vars
          @message = "Unfortunately some errors occurred. Please see the form below, correct the errors and re-submit the information."
          flash.now[:error] = @message
          render :action => "new"      
        else
          @pp = PaymentPackage.for_season_and_division(@registration.season, @registration.division)
          @registration.payment_method = "Credit Card" 
          @registration_questions = @registration.registration_questions
          render :action => :step2
        end
      end
    end
  end

  def finalize
    reg_params = params[:registration]
    comments = reg_params[:comments]
    reg_params.delete(:comments) if comments.blank?  
    @registration = @club.registrations.find_by_id(reg_params[:id])
    @pp = PaymentPackage.for_season_and_division(@registration.season, @registration.division)
    if @registration.update_attributes(reg_params)
      begin
        RegistrationMailer.deliver_public_registration(@registration)
      rescue
        # not going to do anything right now - we'll just log errors
      end
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

    Rails::logger.info "\n\n#{'x'*50}\n\n"
    Rails::logger.info "\n\nrequest to delete registration #{reg_id} received!\n\n"
  
    reg = @club.registrations.find(reg_id)

    Rails::logger.info "\n\nregistration #{reg.id} found, so let's destroy it and all associated person records.\n\n"

    reg.parent_guardian1.destroy unless reg.parent_guardian1.nil?
    reg.parent_guardian2.destroy unless reg.parent_guardian2.nil?
    #reg.registration_people.destroy_all
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
    @person_defaults = {:city => "New Westminster", :province => "BC", :country => "Canada"}
    @player_person_defaults = @person_defaults.merge({:phone_type => "Home"})
  
    @schools = ["Connaught Heights Elementary", "F.W. Howay Elementary", "Glenbrook Middle School", "Herbert Spencer Elementary", "Hume Park Elementary", "John Robson Elementary", "Lord Kelvin Elementary", "Lord Tweedsmuir Elementary", "Queen Elizabeth Elementary", "Queensborough Middle School", "Richard McBride Elementary", "New Westminster Secondary", "Community Education", "Home Learners Program", "Other - Preschool", "Other - Private", "Other - Public"]
    @phone_types = ["Home", "Work", "Cell", "Other"]
    @email_types = ["Home", "Work", "Personal", "Other"]
  end

end