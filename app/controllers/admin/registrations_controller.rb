module Admin
  class RegistrationsController < AdminApplicationController

    def index
      @team = @club.teams.find_by_id(params[:team]) || nil
      @season_division = @club.season_divisions.find_by_id(params[:sd]) || nil
      @season = @club.seasons.find_by_id(params[:season]) || @club.seasons.current.first || nil
      
      if @team
        @registrations = @team.registrations
      elsif @season_division
        @registrations = @season_division.registrations
      elsif @season
        @registrations = @season.registrations
      else
        @registrations = @club.registrations
      end
      
      @registrations = @registrations.by_player_name
    end
    
    def show
      @registration = @club.registrations.find_by_id(params[:id].to_i)
      this = @club.registrations.select("registrations.*, players.*, people.*").joins("inner join players on registrations.player_id = players.id").joins("inner join people on players.person_id = people.id").where("registrations.id = ?", params[:id].to_i).first
      Rails::logger.info "\n\n#{'x'*50}\n\n"
      Rails::logger.info "#{@registration.ai}\n\n"
      
    end
    
  end
end
