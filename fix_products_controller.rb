#!/usr/bin/env ruby

# This script will fix the ProductsController's destroy method
# by replacing the empty? check with a check for nil first element

controller_path = "/rails_app/app/controllers/products_controller.rb"
controller_content = File.read(controller_path)

# Replace the empty? check in destroy method
fixed_content = controller_content.gsub(
  /def destroy.*?requests = firestore_collection\('requests'\)\.where\('product_id', '==', @product\.id\)\.get.*?if requests\.empty\?.*?firestore_document\('products', @product\.id\)\.delete.*?redirect_to products_path, notice: 'Product was successfully deleted\.'.*?else.*?redirect_to products_path, alert: 'Cannot delete product as it is used in requests\.'.*?end.*?end/m,
  "def destroy\n    requests = firestore_collection('requests').where('product_id', '==', @product.id).get\n    first_request = requests.first\n    if first_request.nil?\n      firestore_document('products', @product.id).delete\n      redirect_to products_path, notice: 'Product was successfully deleted.'\n    else\n      redirect_to products_path, alert: 'Cannot delete product as it is used in requests.'\n    end\n  end"
)

# Write the fixed content back to the file
File.write(controller_path, fixed_content)

puts "ProductsController fixed successfully!"
