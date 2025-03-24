#!/usr/bin/env ruby

# This script adds enhanced debugging to the SessionsController
# to help identify where it's hanging during Google OAuth callback

puts "Starting SessionsController debugging script..."

controller_path = "/rails_app/app/controllers/sessions_controller.rb"
puts "Reading controller file from: #{controller_path}"

begin
  controller_content = File.read(controller_path)
  puts "Successfully read controller file (#{controller_content.size} bytes)"
  
  # Add debugging to the create method
  debugged_content = controller_content.gsub(
    /def create.*?end/m,
    %{def create
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
          display_name: auth.info.name
        }
        
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
  end}
  )
  
  # Write the debugged content back to the file
  File.write(controller_path, debugged_content)
  puts "SessionsController debugged successfully!"
  
rescue => e
  puts "ERROR: #{e.message}"
  puts e.backtrace
end
