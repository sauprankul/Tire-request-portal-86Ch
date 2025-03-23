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
    query = firestore_collection('users').where('uid', '==', uid).limit(1)
    docs = query.get
    return nil if docs.empty?
    
    user_data = docs.first.data
    user_data[:id] = docs.first.document_id
    new(user_data)
  end

  def self.find_by_email(email)
    query = firestore_collection('users').where('email', '==', email).limit(1)
    docs = query.get
    return nil if docs.empty?
    
    user_data = docs.first.data
    user_data[:id] = docs.first.document_id
    new(user_data)
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
