class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_approved_user!
  before_action :set_request
  before_action :authorize_message_access!

  def create
    @message = Message.new(
      request_id: @request.id,
      user_id: current_user.id,
      content: params[:message][:content],
      created_at: Time.now
    )
    
    if @message.save
      # In a real application, we would use ActionCable to broadcast the message
      # For now, we'll just redirect back to the request
      redirect_to @request, notice: "Message sent successfully!"
    else
      redirect_to @request, alert: "Failed to send message"
    end
  end

  private

  def set_request
    @request = Request.find(params[:request_id])
  end

  def authorize_message_access!
    # Check if user has permission to send messages to this request
    unless admin? || 
           (participant? && @request.user_id == current_user.id) || 
           (representative? && @request.assigned_rep_id == current_user.id)
      redirect_to dashboard_path, alert: "You don't have permission to send messages to this request"
    end
  end
end
