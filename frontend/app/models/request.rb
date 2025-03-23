class Request
  attr_accessor :id, :user_id, :product_id, :quantity, :payment_type, :status, 
                :assigned_rep_id, :payment_notes, :tracking_number, :shipping_carrier,
                :estimated_arrival, :shipped_date, :received_date, :created_at, :updated_at

  PAYMENT_TYPES = %w[paypal credit_card points].freeze
  STATUSES = %w[SUBMITTED AWAITING_PAYMENT PAID SHIPPED RECEIVED BACKORDERED CANCELED].freeze

  def initialize(attributes = {})
    @id = attributes[:id]
    @user_id = attributes[:user_id]
    @product_id = attributes[:product_id]
    @quantity = attributes[:quantity]
    @payment_type = attributes[:payment_type]
    @status = attributes[:status] || 'SUBMITTED'
    @assigned_rep_id = attributes[:assigned_rep_id]
    @payment_notes = attributes[:payment_notes]
    @tracking_number = attributes[:tracking_number]
    @shipping_carrier = attributes[:shipping_carrier]
    @estimated_arrival = attributes[:estimated_arrival]
    @shipped_date = attributes[:shipped_date]
    @received_date = attributes[:received_date]
    @created_at = attributes[:created_at] || Time.now
    @updated_at = attributes[:updated_at] || Time.now
  end

  def self.find(id)
    doc = firestore_document('requests', id).get
    return nil unless doc.exists?
    
    request_data = doc.data
    request_data[:id] = doc.document_id
    new(request_data)
  end

  def self.all
    docs = firestore_collection('requests').get
    docs.map do |doc|
      request_data = doc.data
      request_data[:id] = doc.document_id
      new(request_data)
    end
  end

  def self.find_by_user_id(user_id)
    query = firestore_collection('requests').where('user_id', '==', user_id)
    docs = query.get
    docs.map do |doc|
      request_data = doc.data
      request_data[:id] = doc.document_id
      new(request_data)
    end
  end

  def self.find_by_representative_id(rep_id)
    query = firestore_collection('requests').where('assigned_rep_id', '==', rep_id)
    docs = query.get
    docs.map do |doc|
      request_data = doc.data
      request_data[:id] = doc.document_id
      new(request_data)
    end
  end

  def self.find_unassigned
    query = firestore_collection('requests').where('assigned_rep_id', '==', nil)
    docs = query.get
    docs.map do |doc|
      request_data = doc.data
      request_data[:id] = doc.document_id
      new(request_data)
    end
  end

  def self.find_by_status(status)
    query = firestore_collection('requests').where('status', '==', status)
    docs = query.get
    docs.map do |doc|
      request_data = doc.data
      request_data[:id] = doc.document_id
      new(request_data)
    end
  end

  def save
    request_data = {
      user_id: @user_id,
      product_id: @product_id,
      quantity: @quantity,
      payment_type: @payment_type,
      status: @status,
      assigned_rep_id: @assigned_rep_id,
      payment_notes: @payment_notes,
      tracking_number: @tracking_number,
      shipping_carrier: @shipping_carrier,
      estimated_arrival: @estimated_arrival,
      shipped_date: @shipped_date,
      received_date: @received_date,
      created_at: @created_at,
      updated_at: Time.now
    }

    if @id
      firestore_document('requests', @id).set(request_data, merge: true)
    else
      doc_ref = firestore_collection('requests').add(request_data)
      @id = doc_ref.document_id
    end

    self
  end

  def user
    User.find(@user_id)
  end

  def product
    Product.find(@product_id)
  end

  def representative
    return nil unless @assigned_rep_id
    User.find(@assigned_rep_id)
  end

  def messages
    Message.find_by_request_id(@id)
  end

  def assign_to_representative(rep_id)
    @assigned_rep_id = rep_id
    save
  end

  def update_status(new_status)
    return false unless STATUSES.include?(new_status)
    
    old_status = @status
    @status = new_status
    
    # Handle points logic for status changes
    if payment_type == 'points' && user.participant?
      points = user.points
      
      if old_status == 'SUBMITTED' && new_status == 'CANCELED'
        # Return points to available if request is canceled
        points_needed = product.points_cost * quantity
        points.cancel_pending(points_needed)
      elsif old_status == 'PAID' && new_status == 'SHIPPED'
        # Move points from pending to redeemed when shipped
        points_needed = product.points_cost * quantity
        points.add_redeemed(points_needed)
      end
    end
    
    save
  end

  def can_be_withdrawn?
    status == 'SUBMITTED'
  end

  def can_be_marked_paid?
    status == 'AWAITING_PAYMENT'
  end

  def can_be_marked_received?
    status == 'SHIPPED'
  end

  def total_cost
    if payment_type == 'points'
      product.points_cost * quantity
    else
      product.price * quantity
    end
  end
end
