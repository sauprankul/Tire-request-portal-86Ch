#!/usr/bin/env ruby
# Users Firestore Test
# Tests basic Firestore operations against the Firebase emulator using the users collection

puts "Starting Users Firestore test..."
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
  # Create a test user ID
  test_user_id = "test-#{SecureRandom.hex(8)}"
  
  puts "\n=== TEST 1: Query Users Collection ==="
  puts "Querying users collection..."
  
  query = firestore.col("users")
  docs = query.get
  
  puts "Query executed, checking results..."
  
  # Method 1: Check if docs.first is nil
  first_doc = docs.first
  puts "Method 1 (first.nil?): #{first_doc.nil? ? 'Collection is empty' : 'Collection has documents'}"
  
  # Method 2: Check if any? returns false
  puts "Method 2 (!any?): #{!docs.any? ? 'Collection is empty' : 'Collection has documents'}"
  
  # Method 3: Count the documents
  count = 0
  docs.each do |doc|
    count += 1
    puts "Found user document: #{doc.document_id}"
  end
  puts "Query returned #{count} documents"
  
  puts "\n=== TEST 2: Query with Where Clause ==="
  if count > 0 && first_doc
    # Get a field from the first document to query by
    user_data = first_doc.data
    email = user_data[:email] || user_data["email"]
    
    if email
      puts "Querying for user with email: #{email}"
      query = firestore.col("users").where("email", "==", email).limit(1)
      docs = query.get
      
      # Check if the query returns the expected document
      first_result = docs.first
      if first_result
        puts "Where query returned document: #{first_result.document_id}"
        puts "PASS: Where clause query works"
      else
        puts "ERROR: Where query did not return any documents"
        puts "FAIL: Where clause query doesn't work"
      end
    else
      puts "No email field found in user document, skipping where clause test"
    end
  else
    puts "No user documents found, skipping where clause test"
  end
  
  puts "\n=== TEST 3: Empty Query Test ==="
  # Use a collection name that likely doesn't exist
  empty_collection = "nonexistent_collection_#{SecureRandom.hex(4)}"
  puts "Testing empty collection: #{empty_collection}"
  query = firestore.col(empty_collection)
  docs = query.get
  
  # Test different ways to check if the query is empty
  puts "Testing empty query handling methods:"
  
  # Method 1: Check if docs.first is nil
  first_doc = docs.first
  puts "Method 1 (first.nil?): #{first_doc.nil? ? 'PASS' : 'FAIL'}"
  
  # Method 2: Check if any? returns false
  puts "Method 2 (!any?): #{!docs.any? ? 'PASS' : 'FAIL'}"
  
  # Method 3: Count the documents (should be 0)
  count = 0
  docs.each { |_| count += 1 }
  puts "Method 3 (count == 0): #{count == 0 ? 'PASS' : 'FAIL'}"
  
  puts "\nAll tests completed successfully!"
  exit 0
rescue => e
  puts "ERROR: #{e.class.name}: #{e.message}"
  puts e.backtrace.join("\n")
  exit 1
end
