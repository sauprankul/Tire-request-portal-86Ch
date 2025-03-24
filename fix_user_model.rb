#!/usr/bin/env ruby

# This script will fix the User model's find_by_uid method
# by replacing the empty? check with a check for nil first element

user_model_path = "/rails_app/app/models/user.rb"
user_model_content = File.read(user_model_path)

# Replace the empty? check in find_by_uid
fixed_content = user_model_content.gsub(
  /def self\.find_by_uid\(uid\).*?query = firestore_collection\('users'\)\.where\('uid', '==', uid\)\.limit\(1\).*?docs = query\.get.*?return nil if docs\.empty\?.*?user_data = docs\.first\.data.*?user_data\[:id\] = docs\.first\.document_id/m,
  "def self.find_by_uid(uid)\n    query = firestore_collection('users').where('uid', '==', uid).limit(1)\n    docs = query.get\n    \n    # Check if there are any results\n    first_doc = docs.first\n    return nil if first_doc.nil?\n    \n    user_data = first_doc.data\n    user_data[:id] = first_doc.document_id"
)

# Replace the empty? check in find_by_email
fixed_content = fixed_content.gsub(
  /def self\.find_by_email\(email\).*?query = firestore_collection\('users'\)\.where\('email', '==', email\)\.limit\(1\).*?docs = query\.get.*?return nil if docs\.empty\?.*?user_data = docs\.first\.data.*?user_data\[:id\] = docs\.first\.document_id/m,
  "def self.find_by_email(email)\n    query = firestore_collection('users').where('email', '==', email).limit(1)\n    docs = query.get\n    \n    # Check if there are any results\n    first_doc = docs.first\n    return nil if first_doc.nil?\n    \n    user_data = first_doc.data\n    user_data[:id] = first_doc.document_id"
)

# Write the fixed content back to the file
File.write(user_model_path, fixed_content)

puts "User model fixed successfully!"
