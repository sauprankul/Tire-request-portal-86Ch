class SessionsController < ApplicationController
  def new
    # Render the sign-in page
  end

  def create
    # Handle OmniAuth callback from Google
    auth = request.env['omniauth.auth']
    
    # Find or create user
    user = User.find_by_uid(auth.uid)
    
    if user
      # Existing user - sign them in
      session[:user_uid] = user.uid
      
      if user.approved?
        redirect_to dashboard_path, notice: "Signed in successfully!"
      else
        redirect_to pending_path
      end
    else
      # New user - redirect to role selection
      session[:auth_data] = {
        uid: auth.uid,
        email: auth.info.email,
        display_name: auth.info.name
      }
      
      redirect_to new_user_path
    end
  end

  def destroy
    session[:user_uid] = nil
    redirect_to root_path, notice: "Signed out successfully!"
  end

  def failure
    redirect_to root_path, alert: "Authentication failed: #{params[:message]}"
  end
end
