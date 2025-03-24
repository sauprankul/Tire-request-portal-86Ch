class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:new, :create, :pending]
  before_action :authenticate_admin!, only: [:index, :approve, :reject]

  def index
    # Admin view of all users - now using ActiveRecord
    @users = User.all
  end

  def new
    # New user registration (role selection)
    Rails.logger.info "===== UsersController#new - Starting ====="
    Rails.logger.info "Session auth_data: #{session[:auth_data].inspect}"
    
    redirect_to dashboard_path if user_signed_in?
    
    # Ensure we have auth data from Google Sign-In
    redirect_to root_path, alert: "Please sign in with Google first" unless session[:auth_data]
    
    # Initialize user with auth data - handle both symbol and string keys
    @user = User.new(
      email: session[:auth_data][:email] || session[:auth_data]['email'],
      display_name: session[:auth_data][:display_name] || session[:auth_data]['display_name']
    )
    
    Rails.logger.info "Rendering new.html.erb with @user: #{@user.inspect}"
    Rails.logger.info "===== UsersController#new - Completed ====="
    
    # Explicitly render the template
    render :new
  end

  def create
    # Create a new user with selected role
    auth_data = session[:auth_data]
    redirect_to root_path, alert: "Please sign in with Google first" unless auth_data
    
    # Verify CAPTCHA (in a real app, this would check reCAPTCHA)
    unless params[:captcha] == "passed"
      flash.now[:alert] = "Please complete the CAPTCHA"
      render :new and return
    end

    # Create the user - handle both symbol and string keys
    @user = User.new(
      uid: auth_data[:uid] || auth_data['uid'],
      email: params[:user][:email],
      display_name: params[:user][:display_name],
      role: params[:user][:role],
      status: 'pending'
    )
    
    # Check if this email is pre-approved as admin
    admin_emails = AdminEmail.pluck(:email)
    if admin_emails.include?(@user.email)
      @user.role = 'admin'
      @user.status = 'approved'
    end
    
    # Save the user
    if @user.save
      # If the user is a participant, create a points record
      if @user.role == 'participant'
        Points.create(
          user_id: @user.id,
          available: 0,
          pending: 0,
          redeemed: 0
        )
      end
      
      # Sign in the user
      session[:user_uid] = @user.uid
      session[:auth_data] = nil
      
      # Notify admins about new user (in a real app, this would send an email)
      notify_admins_about_new_user(@user) unless @user.admin?
      
      if @user.approved?
        redirect_to dashboard_path, notice: "Account created successfully!"
      else
        redirect_to pending_path
      end
    else
      flash.now[:alert] = "Error creating account: #{@user.errors.full_messages.join(', ')}"
      render :new
    end
  end

  def pending
    # Show pending approval page
    @user = current_user
    @debug_info = {}
    @debug_info[:session_user_uid] = session[:user_uid]
    
    # If current_user is nil but we have a user_uid in session, try to find user directly
    if @user.nil? && session[:user_uid]
      uid = session[:user_uid]
      @debug_info[:uid_from_session] = uid
      
      if uid
        # Try to find the user by UID
        @user = User.find_by(uid: uid)
        @debug_info[:user_from_database] = @user.inspect if @user
        
        if @user.nil?
          @debug_info[:error] = "User not found in database by UID"
          
          # Get all users for debugging
          all_users = User.all
          @debug_info[:all_users] = all_users.map { |u| { id: u.id, uid: u.uid, email: u.email } }
        end
      end
    else
      @debug_info[:current_user] = @user.inspect if @user
    end
    
    # If we still don't have a user but have auth_data, create a temporary one
    if @user.nil? && session[:auth_data]
      auth_data = session[:auth_data]
      @debug_info[:auth_data] = auth_data
      
      uid = auth_data[:uid] || auth_data['uid']
      email = auth_data[:email] || auth_data['email']
      display_name = auth_data[:display_name] || auth_data['display_name']
      
      if uid && email && display_name
        @user = User.new(
          uid: uid,
          email: email,
          display_name: display_name,
          role: 'participant',
          status: 'pending'
        )
        @debug_info[:created_temp_user] = true
      end
    end
    
    # Get all users for debugging
    @debug_info[:all_users] = User.all.map { |u| { id: u.id, uid: u.uid, email: u.email } }
    
    redirect_to dashboard_path if @user&.approved?
  end

  def approve
    # Admin approves a user
    user = User.find(params[:id])
    user.status = 'approved'
    
    if user.save
      # Notify the user (in a real app, this would send an email)
      notify_user_about_approval(user)
      redirect_to users_path, notice: "User approved successfully!"
    else
      redirect_to users_path, alert: "Error approving user: #{user.errors.full_messages.join(', ')}"
    end
  end

  def reject
    # Admin rejects a user
    user = User.find(params[:id])
    user.status = 'rejected'
    
    if user.save
      # Notify the user (in a real app, this would send an email)
      notify_user_about_rejection(user)
      redirect_to users_path, notice: "User rejected successfully!"
    else
      redirect_to users_path, alert: "Error rejecting user: #{user.errors.full_messages.join(', ')}"
    end
  end

  private

  def notify_admins_about_new_user(user)
    # In a real app, this would send an email to all admins
    Rails.logger.info("New user registration: #{user.email} as #{user.role}")
  end

  def notify_user_about_approval(user)
    # In a real app, this would send an email to the user
    Rails.logger.info("User approved: #{user.email}")
  end

  def notify_user_about_rejection(user)
    # In a real app, this would send an email to the user
    Rails.logger.info("User rejected: #{user.email}")
  end
end
