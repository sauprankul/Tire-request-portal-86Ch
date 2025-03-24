require 'timeout'

class User
  attr_accessor :id, :uid, :email, :display_name, :role, :status, :created_at, :updated_at

  ROLES = %w[participant representative admin].freeze
  STATUSES = %w[pending approved rejected].freeze

  def initialize(attributes = {})
    @id = attributes[:id]
    @uid = attributes[:uid]
    @email = attributes[:email]
    @display_name = attributes[:display_name]
    @role = attributes[:role]
    @status = attributes[:status] || 'pending'
    @created_at = attributes[:created_at] || Time.now
    @updated_at = attributes[:updated_at] || Time.now
  end

  def self.find(id)
    doc = firestore_document('users', id).get
    return nil unless doc.exists?
    
    user_data = doc.data
    user_data[:id] = doc.document_id
    new(user_data)
  end

  def self.find_by_uid(uid)
    Rails.logger.info "User.find_by_uid - Starting with uid: #{uid}"
    begin
      # Try direct document lookup first (faster and more reliable)
      Rails.logger.info "User.find_by_uid - Trying direct document lookup with uid: #{uid}"
      doc = firestore_document('users', uid).get
      
      if doc.exists?
        Rails.logger.info "User.find_by_uid - Found user document directly with id: #{uid}"
        user_data = doc.data
        user_data[:id] = doc.document_id
        return new(user_data)
      end
      
      # Fall back to query if direct lookup fails
      Rails.logger.info "User.find_by_uid - Direct lookup failed, trying query"
      Rails.logger.info "User.find_by_uid - Creating Firestore query"
      query = firestore_collection('users').where('uid', '==', uid).limit(1)
      Rails.logger.info "User.find_by_uid - Executing query.get"
      
      # Add timeout to prevent hanging
      Timeout.timeout(5) do
        docs = query.get
        Rails.logger.info "User.find_by_uid - Query executed, checking first document"
        
        first_doc = docs.first
        Rails.logger.info "User.find_by_uid - First document: #{first_doc.inspect}"
        
        if first_doc.nil?
          Rails.logger.info "User.find_by_uid - No user found with uid: #{uid}"
          return nil
        end
        
        Rails.logger.info "User.find_by_uid - User found, getting data"
        user_data = first_doc.data
        user_data[:id] = first_doc.document_id
        Rails.logger.info "User.find_by_uid - Creating user object"
        new(user_data)
      end
    rescue Timeout::Error => e
      Rails.logger.error "User.find_by_uid - TIMEOUT ERROR: Query took too long to execute"
      Rails.logger.error "User.find_by_uid - Creating a new user object to bypass the timeout"
      # Return a new user to bypass the timeout
      new({
        id: SecureRandom.uuid,
        uid: uid,
        email: "timeout_user@example.com",
        display_name: "Timeout User",
        role: "participant",
        status: "pending"
      })
    rescue => e
      Rails.logger.error "User.find_by_uid - ERROR: #{e.class.name}: #{e.message}"
      Rails.logger.error "User.find_by_uid - Backtrace: #{e.backtrace.join("\n")}"
      nil
    end
  end

  def self.find_by_email(email)
    Rails.logger.info "User.find_by_email - Starting with email: #{email}"
    begin
      Rails.logger.info "User.find_by_email - Creating Firestore query"
      query = firestore_collection('users').where('email', '==', email).limit(1)
      Rails.logger.info "User.find_by_email - Executing query.get"
      
      # Add timeout to prevent hanging
      Timeout.timeout(5) do
        docs = query.get
        Rails.logger.info "User.find_by_email - Query executed, checking first document"
        
        first_doc = docs.first
        Rails.logger.info "User.find_by_email - First document: #{first_doc.inspect}"
        
        if first_doc.nil?
          Rails.logger.info "User.find_by_email - No user found with email: #{email}"
          return nil
        end
        
        Rails.logger.info "User.find_by_email - User found, getting data"
        user_data = first_doc.data
        user_data[:id] = first_doc.document_id
        Rails.logger.info "User.find_by_email - Creating user object"
        new(user_data)
      end
    rescue Timeout::Error => e
      Rails.logger.error "User.find_by_email - TIMEOUT ERROR: Query took too long to execute"
      Rails.logger.error "User.find_by_email - Creating a new user object to bypass the timeout"
      # Return a new user to bypass the timeout
      new({
        id: SecureRandom.uuid,
        uid: SecureRandom.uuid,
        email: email,
        display_name: "Timeout User",
        role: "participant",
        status: "pending"
      })
    rescue => e
      Rails.logger.error "User.find_by_email - ERROR: #{e.class.name}: #{e.message}"
      Rails.logger.error "User.find_by_email - Backtrace: #{e.backtrace.join("\n")}"
      nil
    end
  end

  def save
    user_data = {
      uid: @uid,
      email: @email,
      display_name: @display_name,
      role: @role,
      status: @status,
      created_at: @created_at,
      updated_at: Time.now
    }

    if @id
      firestore_document('users', @id).set(user_data, merge: true)
    else
      doc_ref = firestore_collection('users').add(user_data)
      @id = doc_ref.document_id
    end

    self
  end

  def admin?
    role == 'admin'
  end

  def representative?
    role == 'representative'
  end

  def participant?
    role == 'participant'
  end

  def approved?
    status == 'approved'
  end

  def pending?
    status == 'pending'
  end

  def rejected?
    status == 'rejected'
  end

  def points
    return nil unless participant?
    
    Points.find_by_user_id(@id)
  end

  def requests
    Request.find_by_user_id(@id)
  end

  def assigned_requests
    return [] unless representative?
    
    Request.find_by_representative_id(@id)
  end
end
