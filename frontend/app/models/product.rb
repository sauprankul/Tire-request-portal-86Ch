class Product
  attr_accessor :id, :name, :description, :image_url, :price, :points_cost, :available, :created_at, :updated_at

  def initialize(attributes = {})
    @id = attributes[:id]
    @name = attributes[:name]
    @description = attributes[:description]
    @image_url = attributes[:image_url]
    @price = attributes[:price]
    @points_cost = attributes[:points_cost]
    @available = attributes[:available] || true
    @created_at = attributes[:created_at] || Time.now
    @updated_at = attributes[:updated_at] || Time.now
  end

  def self.find(id)
    doc = firestore_document('products', id).get
    return nil unless doc.exists?
    
    product_data = doc.data
    product_data[:id] = doc.document_id
    new(product_data)
  end

  def self.all
    docs = firestore_collection('products').get
    docs.map do |doc|
      product_data = doc.data
      product_data[:id] = doc.document_id
      new(product_data)
    end
  end

  def self.available
    query = firestore_collection('products').where('available', '==', true)
    docs = query.get
    docs.map do |doc|
      product_data = doc.data
      product_data[:id] = doc.document_id
      new(product_data)
    end
  end

  def save
    product_data = {
      name: @name,
      description: @description,
      image_url: @image_url,
      price: @price,
      points_cost: @points_cost,
      available: @available,
      created_at: @created_at,
      updated_at: Time.now
    }

    if @id
      firestore_document('products', @id).set(product_data, merge: true)
    else
      doc_ref = firestore_collection('products').add(product_data)
      @id = doc_ref.document_id
    end

    self
  end
end
