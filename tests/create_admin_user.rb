#!/usr/bin/env ruby
# Create Admin User
# Creates an approved admin user in the Firestore database

puts "Starting Create Admin User script..."
puts "Ruby version: #{RUBY_VERSION}"
puts "Loading required libraries..."

begin
  require 'google/cloud/firestore'
  require 'securerandom'
  puts "Libraries loaded successfully"
rescue => e
  puts "ERROR loading libraries: #{e.message}"
  exit 1
end

# Connect to Firestore emulator
puts "Connecting to Firestore emulator at firebase:8080..."
begin
  firestore = Google::Cloud::Firestore.new(
    project_id: "tire-request-portal",
    emulator_host: "firebase:8080"
  )
  puts "Connected to Firestore emulator"
rescue => e
  puts "ERROR connecting to Firestore: #{e.message}"
  puts e.backtrace.join("\n")
  exit 1
end

begin
  # Use the UID from your Google OAuth login
  uid = "101432360857454882761"  # This is the UID from your logs
  email = "saurabh.kulkarni997@gmail.com"  # This is the email from your logs
  
  puts "\n=== Creating Admin User ==="
  puts "Checking if user with UID #{uid} already exists..."
  
  # Check if user exists
  query = firestore.col("users").where("uid", "==", uid).limit(1)
  docs = query.get
  first_doc = docs.first
  
  if first_doc
    puts "User already exists with document ID: #{first_doc.document_id}"
    puts "Updating user to admin with approved status..."
    
    # Update existing user
    user_data = first_doc.data
    user_data[:role] = "admin"
    user_data[:status] = "approved"
    user_data[:updated_at] = Time.now
    
    firestore.doc("users/#{first_doc.document_id}").set(user_data, merge: true)
    puts "User updated successfully!"
    puts "User data: #{user_data}"
  else
    puts "No user found with this UID, creating new admin user..."
    
    # Create new admin user
    user_data = {
      uid: uid,
      email: email,
      display_name: "Admin User",
      role: "admin",
      status: "approved",
      created_at: Time.now,
      updated_at: Time.now
    }
    
    doc_ref = firestore.col("users").add(user_data)
    puts "Created admin user with document ID: #{doc_ref.document_id}"
    puts "User data: #{user_data}"
  end
  
  puts "\nAdmin user creation/update completed successfully!"
  exit 0
rescue => e
  puts "ERROR: #{e.class.name}: #{e.message}"
  puts e.backtrace.join("\n")
  exit 1
end
