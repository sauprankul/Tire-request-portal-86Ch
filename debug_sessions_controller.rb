#!/usr/bin/env ruby

# This script will add debugging to the SessionsController
# to help identify where it's hanging during Google OAuth callback

controller_path = "/rails_app/app/controllers/sessions_controller.rb"
controller_content = File.read(controller_path)

# Add debugging to the create method
debugged_content = controller_content.gsub(
  /def create.*?end/m,
  %{def create
    # Handle OmniAuth callback from Google
    Rails.logger.info "SessionsController#create - Starting"
    auth = request.env['omniauth.auth']
    Rails.logger.info "SessionsController#create - Got auth: \#{auth.uid}, \#{auth.info.email}"
    
    # Find or create user
    Rails.logger.info "SessionsController#create - Looking for user by uid: \#{auth.uid}"
    user = User.find_by_uid(auth.uid)
    Rails.logger.info "SessionsController#create - User found? \#{!user.nil?}"
    
    if user
      # Existing user - sign them in
      Rails.logger.info "SessionsController#create - Setting session user_uid: \#{user.uid}"
      session[:user_uid] = user.uid
      
      Rails.logger.info "SessionsController#create - Checking if user is approved: \#{user.approved?}"
      if user.approved?
        Rails.logger.info "SessionsController#create - User is approved, redirecting to dashboard"
        redirect_to dashboard_path, notice: "Signed in successfully!"
      else
        Rails.logger.info "SessionsController#create - User is not approved, redirecting to pending"
        redirect_to pending_path
      end
    else
      # New user - redirect to role selection
      Rails.logger.info "SessionsController#create - New user, setting auth_data in session"
      session[:auth_data] = {
        uid: auth.uid,
        email: auth.info.email,
        display_name: auth.info.name
      }
      
      Rails.logger.info "SessionsController#create - Redirecting to new_user_path"
      redirect_to new_user_path
    end
  rescue => e
    Rails.logger.error "SessionsController#create - Error: \#{e.message}"
    Rails.logger.error e.backtrace.join("\\n")
    redirect_to root_path, alert: "Authentication error: \#{e.message}"
  end}
)

# Write the debugged content back to the file
File.write(controller_path, debugged_content)

puts "SessionsController debugged successfully!"
