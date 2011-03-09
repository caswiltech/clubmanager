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
  
    @registration = @club.registrations.new(reg_params)
    division = Division.for_season_and_birthdate(@registration.season, @registration.player.birthdate)
    @registration.division = division unless division.nil?
    if division.present? && @registration.save
      Rails::logger.info "\n\n#{@registration.ai}\n\n"
      # proceed to payment choice page  
      @pp = PaymentPackage.for_season_and_division(@registration.season, @registration.division)    
      render :action => :step2
    
      # redirect_to club_path(@club.subdomain)
    else
      Rails::logger.info "\n\n#{'x'*50}\n\n"
      Rails::logger.info "Errors: #{@registration.errors.ai}\n\n"
      Rails::logger.info "\n\n#{'x'*50}\n\n"
      form_vars
      @message = "Unfortunately, some errors occurred. Please see the form below, correct them and re-submit the information."
      @message = "Unfortunately, no team was found matching this player's age for the desired season. If necessary, please correct the player's birthdate." if division.nil?
      flash.now[:error] = @message
      render :action => "new"
    end
  end

  def finalize
    reg_params = params[:registration]
    @registration = Registration.find_by_id(reg_params[:id])
    @pp = PaymentPackage.for_season_and_division(@registration.season, @registration.division)
    if @registration.update_attributes(reg_params)
      render :action => :finalize
    else
      render :action => :step2
    end
  end

  def payment
    reg_id = params[:reg]
    @registration = Registration.find_by_id(reg_id)
    @cc_years = []
    10.times do |i|
      @cc_years << "#{Date.today.year + i}"
    end

  end

  def process_payment
  
  end


  private

  def find_club
    club_id = params[:club_id]
    @club ||= club_id.nil? ? nil : (Club.where(:subdomain => club_id).present? ? Club.where(:subdomain => club_id).first : (Club.where(:id => club_id).present? ? Club.where(:id => club_id).first : nil))
  end

  def find_reg
  
  end

  def form_vars
    @cities = ["Anmore","Burnaby","Coquitlam","Delta","Langley","Maple Ridge","New Westminster","North Vancouver","Pitt Meadows","Port Coquitlam","Port Moody","Richmond","Surrey","Vancouver","West Vancouver","White Rock","Other"]
    @provinces = %w{ BC AB SK MB ON QC NB PE NS NF YK NW NV }
    @person_defaults = {:city => "New Westminster", :province => "BC", :country => "Canada"}
    @player_person_defaults = @person_defaults.merge({:phone_type => "Home"})
  
    @phone_types = ["Home", "Work", "Cell", "Other"]
    @email_types = ["Home", "Work", "Personal", "Other"]
  end

end