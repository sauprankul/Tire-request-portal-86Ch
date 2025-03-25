class AddShippingFieldsToRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :requests, :shipping_name, :string
    add_column :requests, :shipping_phone, :string
    add_column :requests, :shipping_address, :string
    add_column :requests, :shipping_city, :string
    add_column :requests, :shipping_state, :string
    add_column :requests, :shipping_zip, :string
    add_column :requests, :notes, :text
  end
end
