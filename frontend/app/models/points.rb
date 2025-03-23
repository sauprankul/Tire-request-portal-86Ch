class Points
  attr_accessor :id, :user_id, :available, :pending, :redeemed, :created_at, :updated_at

  def initialize(attributes = {})
    @id = attributes[:id]
    @user_id = attributes[:user_id]
    @available = attributes[:available] || 0
    @pending = attributes[:pending] || 0
    @redeemed = attributes[:redeemed] || 0
    @created_at = attributes[:created_at] || Time.now
    @updated_at = attributes[:updated_at] || Time.now
  end

  def self.find(id)
    doc = firestore_document('points', id).get
    return nil unless doc.exists?
    
    points_data = doc.data
    points_data[:id] = doc.document_id
    new(points_data)
  end

  def self.find_by_user_id(user_id)
    query = firestore_collection('points').where('user_id', '==', user_id).limit(1)
    docs = query.get
    return nil if docs.empty?
    
    points_data = docs.first.data
    points_data[:id] = docs.first.document_id
    new(points_data)
  end

  def save
    points_data = {
      user_id: @user_id,
      available: @available,
      pending: @pending,
      redeemed: @redeemed,
      created_at: @created_at,
      updated_at: Time.now
    }

    if @id
      firestore_document('points', @id).set(points_data, merge: true)
    else
      doc_ref = firestore_collection('points').add(points_data)
      @id = doc_ref.document_id
    end

    self
  end

  def total
    @available + @pending + @redeemed
  end

  def add_available(amount)
    @available += amount
    save
  end

  def add_pending(amount)
    @pending += amount
    @available -= amount
    save
  end

  def add_redeemed(amount)
    @redeemed += amount
    @pending -= amount
    save
  end

  def cancel_pending(amount)
    @pending -= amount
    @available += amount
    save
  end

  def tires_available
    @available / 4
  end
end
