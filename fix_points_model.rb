#!/usr/bin/env ruby

# This script will fix the Points model's find_by_user_id method
# by replacing the empty? check with a check for nil first element

points_model_path = "/rails_app/app/models/points.rb"
points_model_content = File.read(points_model_path)

# Replace the empty? check in find_by_user_id
fixed_content = points_model_content.gsub(
  /def self\.find_by_user_id\(user_id\).*?query = firestore_collection\('points'\)\.where\('user_id', '==', user_id\)\.limit\(1\).*?docs = query\.get.*?return nil if docs\.empty\?.*?points_data = docs\.first\.data.*?points_data\[:id\] = docs\.first\.document_id/m,
  "def self.find_by_user_id(user_id)\n    query = firestore_collection('points').where('user_id', '==', user_id).limit(1)\n    docs = query.get\n    \n    # Check if there are any results\n    first_doc = docs.first\n    return nil if first_doc.nil?\n    \n    points_data = first_doc.data\n    points_data[:id] = first_doc.document_id"
)

# Write the fixed content back to the file
File.write(points_model_path, fixed_content)

puts "Points model fixed successfully!"
