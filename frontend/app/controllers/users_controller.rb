class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:new, :create, :pending]
  before_action :authenticate_admin!, only: [:index, :approve, :reject]

  def index
    # Admin view of all users
    query = firestore_collection('users')
    @users = query.get.map do |doc|
      user_data = doc.data
      user_data[:id] = doc.document_id
      User.new(user_data)
    end
  end

  def new
    # New user registration (role selection)
    redirect_to dashboard_path if user_signed_in?
    
    # Ensure we have auth data from Google Sign-In
    redirect_to root_path, alert: "Please sign in with Google first" unless session[:auth_data]
    
    @user = User.new
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

    # Create the user
    @user = User.new(
      uid: auth_data[:uid],
      email: auth_data[:email],
      display_name: auth_data[:display_name],
      role: params[:user][:role],
      status: 'pending',
      created_at: Time.now,
      updated_at: Time.now
    )
    
    # Check if this email is pre-approved as admin
    admin_emails = firestore_collection('admin_emails').get.map { |doc| doc.data['email'] }
    if admin_emails.include?(@user.email)
      @user.role = 'admin'
      @user.status = 'approved'
    end
    
    # Save the user
    @user.save
    
    # If the user is a participant, create a points record
    if @user.role == 'participant'
      Points.new(
        user_id: @user.id,
        available: 0,
        pending: 0,
        redeemed: 0,
        created_at: Time.now,
        updated_at: Time.now
      ).save
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
  end

  def pending
    # Show pending approval page
    @user = current_user
    redirect_to dashboard_path if @user&.approved?
  end

  def approve
    # Admin approves a user
    user = User.find(params[:id])
    user.status = 'approved'
    user.save
    
    # Notify the user (in a real app, this would send an email)
    notify_user_about_approval(user)
    
    redirect_to users_path, notice: "User approved successfully!"
  end

  def reject
    # Admin rejects a user
    user = User.find(params[:id])
    user.status = 'rejected'
    user.save
    
    # Notify the user (in a real app, this would send an email)
    notify_user_about_rejection(user)
    
    redirect_to users_path, notice: "User rejected successfully!"
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
