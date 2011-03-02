class RegistrationsController < ApplicationController
  before_filter :find_club, :except => [:index]
  before_filter :form_vars, :only => [:new]
  

  def index
    @clubs = Club.all
  end
  
  def show
    
  end
  
  def new
    @registration = Registration.new(:club => @club, :season => @club.seasons.first, :payment_method => 'Cheque', :player_attributes => {:person_attributes => @player_person_defaults}, :parent_guardian1_attributes => @person_defaults, :parent_guardian2_attributes => @person_defaults)
  end
  
  def create
    reg_params = params[:registration]
    # Rails::logger.info "\n\n#{'x'*50}\n\n"
    # Rails::logger.info "reg params: #{params.inspect}\n#{params.ai}\n\n"
    @registration = @club.registrations.new(reg_params)

    if @registration.save
      # Rails::logger.info "\n\n#{'x'*50}\n\n"
      # Rails::logger.info "Registration created with ID = #{@registration.id}\n#{@registration.ai}\n\n"
      # Rails::logger.info "\n\n#{'x'*50}\n\n"
    # proceed to payment choice page
      render :action => "choose_payment"
      
      #redirect_to club_path(@club.subdomain)
    else
      # Rails::logger.info "\n\n#{'x'*50}\n\n"
      # Rails::logger.info "Errors: #{@registration.errors.ai}\n\n"
      # Rails::logger.info "\n\n#{'x'*50}\n\n"
      render :action => "new"
    end
  end
  
  def choose_payment
    
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
    
    @phone_types = ["Home", "Work", "Cell", "Other"]
    @email_types = ["Home", "Work", "Personal", "Other"]
  end

end
