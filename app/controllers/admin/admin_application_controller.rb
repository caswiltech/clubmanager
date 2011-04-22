module Admin
  class AdminApplicationController < ::ApplicationController
    # before_filter :login_required

    def find_club
      @club = Club.find(params[:club_id])
    end
    
  end
end
