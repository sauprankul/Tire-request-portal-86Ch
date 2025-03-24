#!/usr/bin/env ruby
# This script adds debug output to the registration page

# Add debug output to the view
view_path = '/rails_app/app/views/users/new.html.erb'
temp_file = '/tmp/new.html.erb'

# Read the current view file
view_content = File.read(view_path)

# Add debug output at the top of the file
debug_output = <<-HTML
<div class="container mt-4 alert alert-info">
  <h5>Debug Information</h5>
  <pre><%= session[:auth_data].inspect %></pre>
</div>
HTML

# Insert the debug output at the beginning of the body content
modified_content = view_content.sub(/<div class="container mt-4">/, "#{debug_output}\n<div class=\"container mt-4\">")

# Write to a temporary file
File.write(temp_file, modified_content)

# Replace the original file
`cp #{temp_file} #{view_path}`

puts "Added debug output to #{view_path}"

# Also modify the controller to ensure auth_data is properly set
controller_path = '/rails_app/app/controllers/users_controller.rb'
temp_controller = '/tmp/users_controller.rb'

# Read the current controller file
controller_content = File.read(controller_path)

# Modify the new action to include more debugging
new_action = <<-RUBY
  def new
    Rails.logger.info "UsersController#new - Starting"
    redirect_to dashboard_path if user_signed_in?
    
    unless session[:auth_data]
      Rails.logger.error "UsersController#new - No auth_data in session"
      redirect_to root_path, alert: "Please sign in with Google first" 
      return
    end
    
    Rails.logger.info "UsersController#new - Auth data in session: \#{session[:auth_data].inspect}"
    
    # Initialize user with auth data
    @user = User.new(
      email: session[:auth_data][:email],
      display_name: session[:auth_data][:display_name]
    )
    
    Rails.logger.info "UsersController#new - Created user: \#{@user.inspect}"
  end
RUBY

# Replace the new action
modified_controller = controller_content.gsub(/def new.*?end/m, new_action)

# Write to a temporary file
File.write(temp_controller, modified_controller)

# Replace the original file
`cp #{temp_controller} #{controller_path}`

puts "Updated controller with additional logging at #{controller_path}"
