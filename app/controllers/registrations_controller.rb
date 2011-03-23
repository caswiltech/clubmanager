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
      @registration = Registration.new(:club => @club, :season => season, :payment_method => 'Credit Card', :player_attributes => {:birthdate => Date.civil(Date.today.years_ago(5).year, 1, 1), :person_attributes => @player_person_defaults}, :parent_guardian1_attributes => @person_defaults)
      @registration.parent_guardian2 = Person.new(@person_defaults)
    else
      redirect_to club_path(@club.subdomain)
    end
  end

  def create    
    reg_params = params[:registration]
    
    @registration = @club.registrations.new(reg_params)
    division = Division.for_season_and_birthdate(@registration.season, @registration.player.birthdate)
    unless division.present?
      @registration.parent_guardian2 = Person.new(reg_params[:parent_guardian2_attributes])
      form_vars
      @message = "Unfortunately no team was found matching this player's age for the desired season. If necessary, please correct the player's birthdate."
      flash.now[:error] = @message
      render :action => "new"
    else
      @registration.division = division
      layer = Layers::PublicRegistration.new(@registration)
      unless layer.save
        @registration.parent_guardian2 = Person.new(reg_params[:parent_guardian2_attributes])
        Rails::logger.info "Errors: #{@registration.errors.ai}\n\n"
        form_vars
        @message = "Unfortunately some errors occurred. Please see the form below, correct the errors and re-submit the information."
        flash.now[:error] = @message
        render :action => "new"      
      else
        @pp = PaymentPackage.for_season_and_division(@registration.season, @registration.division)    
        render :action => :step2
      end
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