class ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!, except: [:index, :show]
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def index
    @products = Product.all
  end

  def show
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(
      name: params[:product][:name],
      description: params[:product][:description],
      image_url: params[:product][:image_url],
      price: params[:product][:price].to_f,
      points_cost: params[:product][:points_cost].to_i,
      available: params[:product][:available] == '1',
      created_at: Time.now,
      updated_at: Time.now
    )
    
    if @product.save
      redirect_to @product, notice: 'Product was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    @product.name = params[:product][:name] if params[:product][:name].present?
    @product.description = params[:product][:description] if params[:product][:description].present?
    @product.image_url = params[:product][:image_url] if params[:product][:image_url].present?
    @product.price = params[:product][:price].to_f if params[:product][:price].present?
    @product.points_cost = params[:product][:points_cost].to_i if params[:product][:points_cost].present?
    @product.available = params[:product][:available] == '1' if params[:product][:available].present?
    @product.updated_at = Time.now
    
    if @product.save
      redirect_to @product, notice: 'Product was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    # Check if product is used in any requests
    requests = firestore_collection('requests').where('product_id', '==', @product.id).get
    
    if requests.empty?
      # Safe to delete
      firestore_document('products', @product.id).delete
      redirect_to products_path, notice: 'Product was successfully deleted.'
    else
      # Product is in use
      redirect_to products_path, alert: 'Cannot delete product as it is used in requests.'
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end
end
