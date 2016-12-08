class DashboardController < ApplicationController
  def index
    redirect_to '/catalog', status: :moved_permanently
  end
end
