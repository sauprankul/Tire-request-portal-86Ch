class RequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_approved_user!
  before_action :set_request, only: [:show, :edit, :update, :assign, :withdraw, :mark_paid, :mark_received]
  before_action :authorize_request_access!, only: [:show, :edit, :update]

  def index
    if admin?
      # Admins can see all requests with filtering
      if params[:status].present?
        @requests = Request.find_by_status(params[:status])
      elsif params[:user_id].present?
        @requests = Request.find_by_user_id(params[:user_id])
      else
        @requests = Request.all
      end
    elsif representative?
      # Representatives see assigned and unassigned requests
      @assigned_requests = Request.find_by_representative_id(current_user.id)
      @unassigned_requests = Request.find_unassigned
      @requests = @assigned_requests + @unassigned_requests
    else
      # Participants see only their requests
      @requests = Request.find_by_user_id(current_user.id)
    end
  end

  def show
    @product = Product.find(@request.product_id)
    @messages = Message.find_by_request_id(@request.id)
    @message = Message.new(request_id: @request.id)
  end

  def new
    authenticate_participant!
    
    # Check if user has too many pending requests
    user_requests = Request.find_by_user_id(current_user.id)
    pending_count = user_requests.count { |r| ['SUBMITTED', 'AWAITING_PAYMENT'].include?(r.status) }
    
    if pending_count >= 5
      redirect_to participant_dashboard_path, alert: "You have 5 or more pending requests. Please wait until some are processed."
      return
    end
    
    @request = Request.new
    @products = Product.available
    @points = current_user.points
  end

  def create
    authenticate_participant!
    
    @product = Product.find(params[:request][:product_id])
    
    @request = Request.new(
      user_id: current_user.id,
      product_id: params[:request][:product_id],
      quantity: params[:request][:quantity],
      payment_type: params[:request][:payment_type],
      status: 'SUBMITTED',
      created_at: Time.now,
      updated_at: Time.now
    )
    
    # Validate quantity
    unless (1..10).include?(@request.quantity.to_i)
      flash.now[:alert] = "Quantity must be between 1 and 10"
      @products = Product.available
      @points = current_user.points
      render :new and return
    end
    
    # If using points, check if user has enough
    if @request.payment_type == 'points'
      points_needed = @product.points_cost * @request.quantity.to_i
      
      if current_user.points.available < points_needed
        flash.now[:alert] = "You don't have enough points for this request"
        @products = Product.available
        @points = current_user.points
        render :new and return
      end
      
      # Reserve the points
      current_user.points.add_pending(points_needed)
    end
    
    # Save the request
    @request.save
    
    redirect_to @request, notice: "Request submitted successfully!"
  end

  def edit
    # Only admins can edit requests
    authenticate_admin!
  end

  def update
    # Only admins can update requests
    authenticate_admin!
    
    @request.update_status(params[:request][:status]) if params[:request][:status].present?
    
    if params[:request][:assigned_rep_id].present?
      @request.assign_to_representative(params[:request][:assigned_rep_id])
    end
    
    if params[:request][:payment_notes].present?
      @request.payment_notes = params[:request][:payment_notes]
    end
    
    if params[:request][:tracking_number].present?
      @request.tracking_number = params[:request][:tracking_number]
    end
    
    if params[:request][:shipping_carrier].present?
      @request.shipping_carrier = params[:request][:shipping_carrier]
    end
    
    if params[:request][:estimated_arrival].present?
      @request.estimated_arrival = params[:request][:estimated_arrival]
    end
    
    @request.save
    
    redirect_to @request, notice: "Request updated successfully!"
  end

  def assign
    # Representatives can assign requests to themselves
    authenticate_representative!
    
    if @request.assigned_rep_id.present? && @request.assigned_rep_id != current_user.id
      redirect_to @request, alert: "This request is already assigned to another representative"
      return
    end
    
    @request.assign_to_representative(current_user.id)
    
    redirect_to @request, notice: "Request assigned to you successfully!"
  end

  def withdraw
    # Participants can withdraw their own requests if in SUBMITTED state
    authenticate_participant!
    
    unless @request.user_id == current_user.id
      redirect_to participant_dashboard_path, alert: "You can only withdraw your own requests"
      return
    end
    
    unless @request.can_be_withdrawn?
      redirect_to @request, alert: "This request cannot be withdrawn"
      return
    end
    
    # If using points, return them to available
    if @request.payment_type == 'points'
      product = Product.find(@request.product_id)
      points_to_return = product.points_cost * @request.quantity
      current_user.points.cancel_pending(points_to_return)
    end
    
    @request.update_status('CANCELED')
    
    redirect_to participant_dashboard_path, notice: "Request withdrawn successfully!"
  end

  def mark_paid
    # Participants can mark their requests as paid
    authenticate_participant!
    
    unless @request.user_id == current_user.id
      redirect_to participant_dashboard_path, alert: "You can only update your own requests"
      return
    end
    
    unless @request.can_be_marked_paid?
      redirect_to @request, alert: "This request cannot be marked as paid"
      return
    end
    
    @request.update_status('PAID')
    
    # Add a system message
    Message.new(
      request_id: @request.id,
      user_id: current_user.id,
      content: "Request marked as PAID by #{current_user.display_name}",
      created_at: Time.now
    ).save
    
    redirect_to @request, notice: "Request marked as paid!"
  end

  def mark_received
    # Participants can mark their requests as received
    authenticate_participant!
    
    unless @request.user_id == current_user.id
      redirect_to participant_dashboard_path, alert: "You can only update your own requests"
      return
    end
    
    unless @request.can_be_marked_received?
      redirect_to @request, alert: "This request cannot be marked as received"
      return
    end
    
    @request.received_date = Time.now
    @request.update_status('RECEIVED')
    
    # Add a system message
    Message.new(
      request_id: @request.id,
      user_id: current_user.id,
      content: "Request marked as RECEIVED by #{current_user.display_name}",
      created_at: Time.now
    ).save
    
    redirect_to @request, notice: "Request marked as received!"
  end

  private

  def set_request
    @request = Request.find(params[:id])
  end

  def authorize_request_access!
    # Check if user has permission to access this request
    unless admin? || 
           (participant? && @request.user_id == current_user.id) || 
           (representative? && (@request.assigned_rep_id == current_user.id || @request.assigned_rep_id.nil?))
      redirect_to dashboard_path, alert: "You don't have permission to access this request"
    end
  end
end
