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
    @debug_info = {}
    @debug_info[:session_user_uid] = session[:user_uid]
    
    # If current_user is nil but we have a user_uid in session, try to find user directly
    if @user.nil? && session[:user_uid]
      uid = session[:user_uid]
      @debug_info[:uid_from_session] = uid
      
      if uid
        # Try to find the user in Firebase by UID
        begin
          Rails.logger.info "Pending action - Looking for user by uid: #{uid}"
          
          # First try to find the user with the User model method
          @user = User.find_by_uid(uid)
          @debug_info[:user_from_model_method] = @user.inspect
          
          # If that fails, try a direct query
          if @user.nil?
            Rails.logger.info "Pending action - User not found by model method, trying direct query"
            query = FIRESTORE.col('users').where('uid', '==', uid).limit(1)
            docs = query.get
            first_doc = docs.first
            
            @debug_info[:query_result] = "Query executed"
            @debug_info[:first_doc] = first_doc.inspect if first_doc
            
            if first_doc
              Rails.logger.info "Pending action - User found in Firebase"
              user_data = first_doc.data
              @debug_info[:user_data] = user_data
              
              # Create a new hash to avoid modifying the frozen hash
              mutable_user_data = user_data.transform_keys(&:to_sym)
              mutable_user_data[:id] = first_doc.document_id
              
              @debug_info[:document_id] = first_doc.document_id
              @debug_info[:mutable_user_data] = mutable_user_data
              
              # Create a new User object with the data
              @user = User.new(mutable_user_data)
              
              # Set the session user_uid to ensure user_signed_in? returns true
              session[:user_uid] = @user.uid
            else
              Rails.logger.info "Pending action - User not found in Firebase by UID"
              @debug_info[:error] = "User not found in Firebase by UID"
              
              # If we have a user in the all_users list with this UID, use that
              all_users_data = []
              begin
                all_users_query = FIRESTORE.col('users').get
                all_users_query.each do |doc|
                  user_data = doc.data
                  user_data[:id] = doc.document_id
                  all_users_data << { id: doc.document_id, data: user_data }
                  
                  # If we find a user with matching UID, use it
                  if user_data['uid'] == uid
                    Rails.logger.info "Found user with matching UID in all_users"
                    # Create a new hash to avoid modifying the frozen hash
                    mutable_user_data = user_data.transform_keys(&:to_sym)
                    mutable_user_data[:id] = doc.document_id
                    @user = User.new(mutable_user_data)
                    @debug_info[:user_found_in_all_users] = true
                    break
                  end
                end
                @debug_info[:all_users] = all_users_data
              rescue => e
                Rails.logger.error "Error querying all users: #{e.message}"
                @debug_info[:all_users_error] = e.message
              end
            end
          end
        rescue => e
          Rails.logger.error "Pending action - Error querying Firebase: #{e.message}"
          @debug_info[:error] = e.message
          @debug_info[:backtrace] = e.backtrace.join("\n")
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
    begin
      all_users_data = []
      all_users_query = FIRESTORE.col('users').get
      all_users_query.each do |doc|
        user_data = doc.data
        all_users_data << { id: doc.document_id, data: user_data }
      end
      @debug_info[:all_users] = all_users_data
    rescue => e
      @debug_info[:all_users_error] = e.message
    end
    
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
