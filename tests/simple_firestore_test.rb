#!/usr/bin/env ruby
# Simple Firestore Test
# Tests basic Firestore operations against the Firebase emulator

puts "Starting simple Firestore test..."
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

# Test collection name
test_collection = "test_collection_#{SecureRandom.hex(4)}"
puts "Using test collection: #{test_collection}"

# Test document data
doc_id = SecureRandom.uuid
doc_data = {
  test_id: doc_id,
  name: "Test Document",
  created_at: Time.now.to_s
}

begin
  puts "\n=== TEST 1: Create Document ==="
  puts "Creating document with ID: #{doc_id}"
  doc_ref = firestore.doc("#{test_collection}/#{doc_id}")
  doc_ref.set(doc_data)
  puts "Document created"

  puts "\n=== TEST 2: Get Document ==="
  puts "Getting document with ID: #{doc_id}"
  doc = doc_ref.get
  if doc.exists?
    puts "Document exists: #{doc.document_id}"
    puts "Document data: #{doc.data}"
  else
    puts "ERROR: Document does not exist"
    exit 1
  end

  puts "\n=== TEST 3: Query Documents ==="
  puts "Querying collection: #{test_collection}"
  query = firestore.col(test_collection)
  docs = query.get
  puts "Query executed, checking results..."

  # Check if we can iterate through the documents
  count = 0
  docs.each do |doc|
    count += 1
    puts "Found document: #{doc.document_id}"
  end

  puts "Query returned #{count} documents"

  puts "\n=== TEST 4: Query with Where Clause ==="
  puts "Querying with where clause..."
  query = firestore.col(test_collection).where("test_id", "==", doc_id).limit(1)
  puts "Executing query..."
  docs = query.get
  puts "Query executed, checking results..."

  # Check if the query returns the expected document
  first_doc = docs.first
  if first_doc
    puts "Where query returned document: #{first_doc.document_id}"
  else
    puts "ERROR: Where query did not return any documents"
    exit 1
  end

  puts "\n=== TEST 5: Empty Query Test ==="
  empty_collection = "empty_collection_#{SecureRandom.hex(4)}"
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
