class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_approved_user!

  def index
    # Redirect to the appropriate dashboard based on user role
    if admin? && params[:view] != 'participant'
      redirect_to admin_dashboard_path
    elsif representative?
      redirect_to representative_dashboard_path
    else
      redirect_to participant_dashboard_path
    end
  end

  def participant
    # Participant dashboard
    authenticate_participant!
    
    @user = current_user
    @points = @user.points
    @requests = Request.find_by_user_id(@user.id)
    @products = Product.available
  end

  def representative
    # Representative dashboard
    authenticate_representative!
    
    @user = current_user
    @assigned_requests = Request.find_by_representative_id(@user.id)
    @unassigned_requests = Request.find_unassigned
  end

  def admin
    # Admin dashboard
    authenticate_admin!
    
    @user = current_user
    
    # Filter requests based on parameters
    if params[:status].present?
      @requests = Request.find_by_status(params[:status])
    elsif params[:user_id].present?
      @requests = Request.find_by_user_id(params[:user_id])
    else
      @requests = Request.all
    end
    
    @users = firestore_collection('users').get.map do |doc|
      user_data = doc.data
      user_data[:id] = doc.document_id
      User.new(user_data)
    end
    
    @pending_users = @users.select { |user| user.pending? }
  end

  def switch_view
    # Admin switching between admin and participant view
    authenticate_admin!
    
    if params[:view] == 'participant'
      redirect_to participant_dashboard_path
    else
      redirect_to admin_dashboard_path
    end
  end
end
