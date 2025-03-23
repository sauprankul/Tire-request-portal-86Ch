class PointsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!, except: [:show]
  before_action :set_user, only: [:show, :edit, :update]

  def index
    # Admin view of all points
    @users = firestore_collection('users')
      .where('role', '==', 'participant')
      .get
      .map do |doc|
        user_data = doc.data
        user_data[:id] = doc.document_id
        User.new(user_data)
      end
    
    @points = @users.map do |user|
      Points.find_by_user_id(user.id)
    end.compact
  end

  def show
    # View points for a specific user
    @points = Points.find_by_user_id(@user.id)
    
    unless admin? || current_user.id == @user.id
      redirect_to dashboard_path, alert: "You don't have permission to view these points"
    end
  end

  def edit
    # Admin editing points for a user
    @points = Points.find_by_user_id(@user.id)
  end

  def update
    # Admin updating points for a user
    @points = Points.find_by_user_id(@user.id)
    
    if params[:points][:add_available].present?
      amount = params[:points][:add_available].to_i
      @points.add_available(amount)
      
      # Add a system message to notify the user
      Message.new(
        request_id: nil,
        user_id: current_user.id,
        content: "#{amount} points added to your account by admin",
        created_at: Time.now
      ).save
    end
    
    redirect_to points_path, notice: "Points updated successfully!"
  end

  def bulk_update
    # Admin bulk updating points for multiple users
    if params[:user_ids].present? && params[:points_amount].present?
      user_ids = params[:user_ids]
      amount = params[:points_amount].to_i
      
      user_ids.each do |user_id|
        points = Points.find_by_user_id(user_id)
        points.add_available(amount) if points
      end
      
      redirect_to points_path, notice: "Points updated for #{user_ids.size} users!"
    else
      redirect_to points_path, alert: "Please select users and enter points amount"
    end
  end

  private

  def set_user
    @user = User.find(params[:id] || params[:user_id])
  end
end
