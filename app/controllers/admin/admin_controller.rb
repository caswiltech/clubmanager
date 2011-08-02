module Admin
  class AdminController < AdminApplicationController

    def index
      @current_seasons = @club.seasons.current
      @past_seasons = @club.seasons.past
      @divisions = @club.divisions
      
    end
    
  end
end
