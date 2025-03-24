#!/usr/bin/env ruby
# Create Approved User
# Creates an approved admin user in the Firestore database with a specific UID

puts "Starting Create Approved User script..."
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
puts "Connecting to Firestore emulator..."
puts "FIRESTORE_EMULATOR_HOST environment variable: #{ENV['FIRESTORE_EMULATOR_HOST']}"

begin
  firestore = Google::Cloud::Firestore.new(
    project_id: "tire-request-portal"
    # No need to specify emulator_host here, it will use the FIRESTORE_EMULATOR_HOST env variable
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
  
  puts "\n=== Creating Approved Admin User ==="
  puts "Creating/updating user with UID #{uid}..."
  
  # Create user document directly
  user_data = {
    uid: uid,
    email: email,
    display_name: "Admin User",
    role: "admin",
    status: "approved",
    created_at: Time.now,
    updated_at: Time.now
  }
  
  # Use the UID as the document ID for easy lookup
  doc_ref = firestore.doc("users/#{uid}")
  doc_ref.set(user_data)
  
  puts "Created/updated admin user with document ID: #{uid}"
  puts "User data: #{user_data}"
  
  puts "\nAdmin user creation/update completed successfully!"
  exit 0
rescue => e
  puts "ERROR: #{e.class.name}: #{e.message}"
  puts e.backtrace.join("\n")
  exit 1
end
