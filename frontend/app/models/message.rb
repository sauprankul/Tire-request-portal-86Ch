class Message
  attr_accessor :id, :request_id, :user_id, :content, :created_at

  def initialize(attributes = {})
    @id = attributes[:id]
    @request_id = attributes[:request_id]
    @user_id = attributes[:user_id]
    @content = attributes[:content]
    @created_at = attributes[:created_at] || Time.now
  end

  def self.find(id, request_id)
    doc = firestore_document("requests/#{request_id}/messages", id).get
    return nil unless doc.exists?
    
    message_data = doc.data
    message_data[:id] = doc.document_id
    message_data[:request_id] = request_id
    new(message_data)
  end

  def self.find_by_request_id(request_id)
    query = firestore_collection("requests/#{request_id}/messages").order('created_at', :asc)
    docs = query.get
    docs.map do |doc|
      message_data = doc.data
      message_data[:id] = doc.document_id
      message_data[:request_id] = request_id
      new(message_data)
    end
  end

  def save
    message_data = {
      user_id: @user_id,
      content: @content,
      created_at: @created_at
    }

    if @id
      firestore_document("requests/#{@request_id}/messages", @id).set(message_data, merge: true)
    else
      doc_ref = firestore_collection("requests/#{@request_id}/messages").add(message_data)
      @id = doc_ref.document_id
    end

    # After saving a message, we should notify the other party
    notify_other_party

    self
  end

  def user
    User.find(@user_id)
  end

  def request
    Request.find(@request_id)
  end

  private

  def notify_other_party
    # This would be implemented to send an email notification
    # In a real application, this would use ActionMailer or a background job
    # For now, we'll just log the notification
    Rails.logger.info("Message notification: New message from #{user.display_name} on request #{@request_id}")
  end
end
