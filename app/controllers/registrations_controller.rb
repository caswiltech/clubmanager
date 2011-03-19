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
      @registration = Registration.new(:club => @club, :season => season, :payment_method => 'Credit Card', :player_attributes => {:person_attributes => @player_person_defaults}, :parent_guardian1_attributes => @person_defaults, :parent_guardian2_attributes => @person_defaults)
    else
      redirect_to club_path(@club.subdomain)
    end
  end

  def create
    reg_params = params[:registration]
    # let's cleanup the params for parent guardian1
    pg1_params = reg_params.delete(:parent_guardian1_attributes)
    street = pg1_params[:street1]
    if street.empty?
      pg1_params.delete(:street1)
      pg1_params.delete(:street2)
      pg1_params.delete(:city)
      pg1_params.delete(:province)
      pg1_params.delete(:country)
    end
    phone = pg1_params[:phone]
    if phone.empty?
      pg1_params.delete(:phone)
      pg1_params.delete(:phone_type)
    end      
    alt_phone = pg1_params[:alt_phone]
    if alt_phone.empty?
      pg1_params.delete(:alt_phone)
      pg1_params.delete(:alt_phone_type)
    end      
    email = pg1_params[:email]
    if email.empty?
      pg1_params.delete(:email)
      pg1_params.delete(:email_type)
    end      
    alt_email = pg1_params[:alt_email]
    if alt_email.empty?
      pg1_params.delete(:alt_email)
      pg1_params.delete(:alt_email_type)
    end
    reg_params[:parent_guardian1_attributes] = pg1_params
        
    # let's remove the params for the second parent-guardian if they're not specified
    pg2_params = reg_params.delete(:parent_guardian2_attributes)
    if pg2_params[:last_name].present? && pg2_params[:last_name].present?
      street = pg2_params[:street1]
      if street.empty?
        pg2_params.delete(:street1)
        pg2_params.delete(:street2)
        pg2_params.delete(:city)
        pg2_params.delete(:province)
        pg2_params.delete(:country)
      end
      phone = pg2_params[:phone]
      if phone.empty?
        pg2_params.delete(:phone)
        pg2_params.delete(:phone_type)
      end      
      alt_phone = pg2_params[:alt_phone]
      if alt_phone.empty?
        pg2_params.delete(:alt_phone)
        pg2_params.delete(:alt_phone_type)
      end      
      email = pg2_params[:email]
      if email.empty?
        pg2_params.delete(:email)
        pg2_params.delete(:email_type)
      end      
      alt_email = pg2_params[:alt_email]
      if alt_email.empty?
        pg2_params.delete(:alt_email)
        pg2_params.delete(:alt_email_type)
      end
      reg_params[:parent_guardian2_attributes] = pg2_params
    end
  
    @registration = @club.registrations.new(reg_params)
    division = Division.for_season_and_birthdate(@registration.season, @registration.player.birthdate)
    @registration.division = division unless division.nil?
    if division.present? && @registration.save
      @pp = PaymentPackage.for_season_and_division(@registration.season, @registration.division)    
      render :action => :step2
    else
      Rails::logger.info "Errors: #{@registration.errors.ai}\n\n"
      form_vars
      @message = "Unfortunately, some errors occurred. Please see the form below, correct them and re-submit the information."
      @message = "Unfortunately, no team was found matching this player's age for the desired season. If necessary, please correct the player's birthdate." if division.nil?
      flash.now[:error] = @message
      render :action => "new"
    end
  end

  def finalize
    reg_params = params[:registration]
    comments = reg_params[:comments]
    reg_params.delete(:comments) if comments.empty?  
    @registration = Registration.find_by_id(reg_params[:id])
    @pp = PaymentPackage.for_season_and_division(@registration.season, @registration.division)
    if @registration.update_attributes(reg_params)
      RegistrationMailer.deliver_public_registration(@registration)
      render :action => :finalize
    else
      Rails::logger.info "Errors: #{@registration.errors.ai}\n\n"
      render :action => :step2
    end
  end
  
  def regreport
    @registrations = @club.registrations.order("id desc")
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