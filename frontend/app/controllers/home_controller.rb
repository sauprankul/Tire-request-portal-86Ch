class HomeController < ApplicationController
  def index
    # If user is signed in and approved, redirect to dashboard
    if user_signed_in? && current_user.approved?
      redirect_to dashboard_path
    end
    
    # Otherwise, show the landing page
  end
end
