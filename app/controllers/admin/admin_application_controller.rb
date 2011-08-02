module Admin
  class AdminApplicationController < ::ApplicationController
    # before_filter :login_required
    before_filter :find_club

    def find_club
      @club = Club.first#Club.find(params[:club_id])
    end
    
  end
end
