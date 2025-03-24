class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user, :user_signed_in?, :admin?, :representative?, :participant?

  private

  def current_user
    return @current_user if defined?(@current_user)
    
    if session[:user_uid]
      Rails.logger.info "Looking for user with UID: #{session[:user_uid]}"
      # Find user by UID using ActiveRecord
      @current_user = User.find_by(uid: session[:user_uid])
      
      if @current_user.nil?
        Rails.logger.info "User not found by uid: #{session[:user_uid]}"
      else
        Rails.logger.info "User found: #{@current_user.email}"
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

  # This method is kept for backward compatibility but now returns nil
  # as we're no longer using Firestore
  def firestore_collection(collection_name)
    Rails.logger.warn "firestore_collection called but we're using PostgreSQL now"
    nil
  end
end
