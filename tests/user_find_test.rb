#!/usr/bin/env ruby
# User Find Test
# Tests the User.find_by_uid method with a specific UID

puts "Starting User Find Test..."
puts "Ruby version: #{RUBY_VERSION}"
puts "Loading required libraries..."

begin
  require 'google/cloud/firestore'
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

# Test UID from the logs
test_uid = "101432360857454882761"

begin
  puts "\n=== TEST: Find User by UID ==="
  puts "Looking for user with UID: #{test_uid}"
  
  # Create a test user if it doesn't exist
  puts "First, creating a test user with this UID if it doesn't exist..."
  
  # Check if user exists
  query = firestore.col("users").where("uid", "==", test_uid).limit(1)
  docs = query.get
  first_doc = docs.first
  
  if first_doc.nil?
    puts "No user found with this UID, creating one..."
    user_data = {
      uid: test_uid,
      email: "test_user@example.com",
      display_name: "Test User",
      role: "participant",
      status: "approved",
      created_at: Time.now,
      updated_at: Time.now
    }
    
    doc_ref = firestore.col("users").add(user_data)
    puts "Created user with document ID: #{doc_ref.document_id}"
  else
    puts "User already exists with document ID: #{first_doc.document_id}"
  end
  
  # Now test the query again
  puts "\nTesting query for user with UID: #{test_uid}"
  
  # Method 1: Direct query
  puts "Method 1: Direct query"
  query = firestore.col("users").where("uid", "==", test_uid).limit(1)
  start_time = Time.now
  docs = query.get
  end_time = Time.now
  puts "Query execution time: #{(end_time - start_time) * 1000} ms"
  
  first_doc = docs.first
  if first_doc.nil?
    puts "ERROR: User not found with UID: #{test_uid}"
  else
    puts "User found with document ID: #{first_doc.document_id}"
    puts "User data: #{first_doc.data}"
  end
  
  # Method 2: Get all users and filter
  puts "\nMethod 2: Get all users and filter"
  start_time = Time.now
  all_users = firestore.col("users").get
  end_time = Time.now
  puts "Query execution time: #{(end_time - start_time) * 1000} ms"
  
  found = false
  all_users.each do |doc|
    if doc.data["uid"] == test_uid || doc.data[:uid] == test_uid
      puts "User found with document ID: #{doc.document_id}"
      puts "User data: #{doc.data}"
      found = true
      break
    end
  end
  
  puts "ERROR: User not found in all users" unless found
  
  puts "\nAll tests completed successfully!"
  exit 0
rescue => e
  puts "ERROR: #{e.class.name}: #{e.message}"
  puts e.backtrace.join("\n")
  exit 1
end
