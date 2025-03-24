class SessionsController < ApplicationController
  def new
    # Render the sign-in page
  end

  def create
    # Handle OmniAuth callback from Google
    Rails.logger.info "===== SessionsController#create - Starting ====="
    Rails.logger.info "Request parameters: #{request.params.inspect}"
    
    begin
      Rails.logger.info "Getting auth from request.env['omniauth.auth']"
      auth = request.env['omniauth.auth']
      Rails.logger.info "Auth object class: #{auth.class.name}"
      Rails.logger.info "Auth details: uid=#{auth.uid}, provider=#{auth.provider}, info.email=#{auth.info.email}"
      
      # Find or create user
      Rails.logger.info "Looking for user by uid: #{auth.uid}"
      user = User.find_by_uid(auth.uid)
      Rails.logger.info "User lookup result: #{user.inspect}"
      
      if user
        # Existing user - sign them in
        Rails.logger.info "Setting session user_uid: #{user.uid}"
        session[:user_uid] = user.uid
        
        Rails.logger.info "Checking if user is approved: #{user.approved?}"
        if user.approved?
          Rails.logger.info "User is approved, redirecting to dashboard"
          redirect_to dashboard_path, notice: "Signed in successfully!"
        else
          Rails.logger.info "User is not approved, redirecting to pending"
          redirect_to pending_path
        end
      else
        # New user - redirect to role selection
        Rails.logger.info "New user, setting auth_data in session"
        session[:auth_data] = {
          uid: auth.uid,
          email: auth.info.email,
          display_name: auth.info.name,
          provider: auth.provider
        }
        
        Rails.logger.info "Session auth_data: #{session[:auth_data].inspect}"
        Rails.logger.info "Redirecting to new_user_path"
        redirect_to new_user_path
      end
      Rails.logger.info "===== SessionsController#create - Completed ====="
    rescue => e
      Rails.logger.error "===== SessionsController#create - ERROR ====="
      Rails.logger.error "Error class: #{e.class.name}"
      Rails.logger.error "Error message: #{e.message}"
      Rails.logger.error "Backtrace: #{e.backtrace.join("\n")}"
      redirect_to root_path, alert: "Authentication error: #{e.message}"
    end
  end

  def destroy
    session[:user_uid] = nil
    redirect_to root_path, notice: "Signed out successfully!"
  end

  def failure
    Rails.logger.error "===== SessionsController#failure - Authentication Failed ====="
    Rails.logger.error "Failure message: #{params[:message]}"
    Rails.logger.error "Strategy: #{params[:strategy]}"
    
    flash[:alert] = "Authentication failed: #{params[:message] || 'Unknown error'}"
    redirect_to root_path
  end
end
