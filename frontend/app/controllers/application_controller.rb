class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user, :user_signed_in?, :admin?, :representative?, :participant?

  private

  def current_user
    return @current_user if defined?(@current_user)
    
    if session[:user_uid]
      Rails.logger.info "Looking for user with UID: #{session[:user_uid]}"
      # Try to find the user by UID
      @current_user = User.find_by_uid(session[:user_uid])
      
      # If not found, try to find by querying directly
      if @current_user.nil?
        Rails.logger.info "User not found by find_by_uid, trying direct query"
        begin
          query = firestore_collection('users').where('uid', '==', session[:user_uid]).limit(1)
          docs = query.get
          first_doc = docs.first
          
          if first_doc
            Rails.logger.info "User found in Firebase by query"
            user_data = first_doc.data
            user_data[:id] = first_doc.document_id
            @current_user = User.new(user_data)
          else
            Rails.logger.info "User not found in Firebase by query either"
          end
        rescue => e
          Rails.logger.error "Error querying Firebase for user: #{e.message}"
        end
      end
    end
    
    @current_user
  end

  def user_signed_in?
    !!current_user
  end

  def admin?
    user_signed_in? && current_user.admin?
  end

  def representative?
    user_signed_in? && current_user.representative?
  end

  def participant?
    user_signed_in? && current_user.participant?
  end

  def authenticate_user!
    unless user_signed_in?
      flash[:alert] = "You need to sign in before continuing."
      redirect_to root_path
    end
  end

  def authenticate_admin!
    unless admin?
      flash[:alert] = "You don't have permission to access this page."
      redirect_to root_path
    end
  end

  def authenticate_representative!
    unless representative? || admin?
      flash[:alert] = "You don't have permission to access this page."
      redirect_to root_path
    end
  end

  def authenticate_participant!
    unless participant? || admin?
      flash[:alert] = "You don't have permission to access this page."
      redirect_to root_path
    end
  end

  def authenticate_approved_user!
    if user_signed_in? && !current_user.approved?
      flash[:alert] = "Your account is pending approval."
      redirect_to pending_path
    end
  end

  def firestore_collection(collection_name)
    # Use the global FIRESTORE constant directly
    FIRESTORE.col(collection_name)
  end
end
