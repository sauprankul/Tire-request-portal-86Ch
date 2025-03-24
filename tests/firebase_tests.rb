#!/usr/bin/env ruby
# Firebase Emulator Tests
# This script tests basic Firestore operations against the Firebase emulator

require 'google/cloud/firestore'
require 'securerandom'
require 'logger'

# Set up logger
logger = Logger.new(STDOUT)
logger.level = Logger::INFO
logger.formatter = proc do |severity, datetime, progname, msg|
  "#{datetime.strftime('%Y-%m-%d %H:%M:%S')} [#{severity}] #{msg}\n"
end

# Test class to run Firestore tests
class FirestoreTests
  attr_reader :firestore, :logger

  def initialize(logger)
    @logger = logger
    @logger.info("Initializing Firestore tests")
    
    # Connect to Firestore emulator
    @firestore = Google::Cloud::Firestore.new(
      project_id: "tire-request-portal",
      emulator_host: "localhost:8080"
    )
    
    @logger.info("Connected to Firestore emulator")
    @test_collections = ["test_users", "test_points", "test_products", "test_requests"]
  end

  def run_all_tests
    @logger.info("Starting all Firestore tests")
    
    begin
      cleanup_test_data
      test_create_document
      test_get_document
      test_query_documents
      test_update_document
      test_delete_document
      test_batch_operations
      test_transaction
      test_empty_query_handling
      
      @logger.info("All tests completed successfully!")
      return true
    rescue => e
      @logger.error("Test failed: #{e.message}")
      @logger.error(e.backtrace.join("\n"))
      return false
    ensure
      cleanup_test_data
    end
  end

  def cleanup_test_data
    @logger.info("Cleaning up test data")
    
    @test_collections.each do |collection_name|
      @logger.info("Cleaning up collection: #{collection_name}")
      
      # Get all documents in the collection
      docs = @firestore.col(collection_name).get
      
      # Delete each document
      docs.each do |doc|
        @firestore.doc("#{collection_name}/#{doc.document_id}").delete
        @logger.info("Deleted document: #{collection_name}/#{doc.document_id}")
      end
    end
  end

  def test_create_document
    @logger.info("Testing document creation")
    
    # Create a test user
    user_id = SecureRandom.uuid
    user_data = {
      uid: "test-uid-#{user_id}",
      email: "test-#{user_id}@example.com",
      display_name: "Test User #{user_id}",
      role: "participant",
      status: "pending",
      created_at: Time.now,
      updated_at: Time.now
    }
    
    # Add the document to Firestore
    doc_ref = @firestore.col("test_users").add(user_data)
    
    # Verify the document was created
    doc = @firestore.doc("test_users/#{doc_ref.document_id}").get
    
    if doc.exists?
      @logger.info("Document created successfully: test_users/#{doc_ref.document_id}")
    else
      raise "Failed to create document"
    end
    
    # Return the document ID for use in other tests
    doc_ref.document_id
  end

  def test_get_document
    @logger.info("Testing document retrieval")
    
    # Create a test document
    doc_id = test_create_document
    
    # Get the document
    doc = @firestore.doc("test_users/#{doc_id}").get
    
    if doc.exists?
      @logger.info("Document retrieved successfully: test_users/#{doc_id}")
      @logger.info("Document data: #{doc.data}")
    else
      raise "Failed to retrieve document"
    end
    
    doc_id
  end

  def test_query_documents
    @logger.info("Testing document querying")
    
    # Create several test documents
    user_ids = []
    3.times do
      user_ids << test_create_document
    end
    
    # Query all documents in the collection
    query = @firestore.col("test_users")
    docs = query.get
    
    # Check if we can iterate through the documents
    count = 0
    docs.each do |doc|
      count += 1
      @logger.info("Found document: test_users/#{doc.document_id}")
    end
    
    if count >= 3
      @logger.info("Query returned #{count} documents")
    else
      raise "Query did not return expected number of documents (expected at least 3, got #{count})"
    end
    
    # Test query with where clause
    first_doc = @firestore.doc("test_users/#{user_ids.first}").get
    email = first_doc.data[:email]
    
    @logger.info("Testing query with where clause for email: #{email}")
    query = @firestore.col("test_users").where("email", "==", email).limit(1)
    docs = query.get
    
    # Check if the query returns the expected document
    first_result = docs.first
    if first_result
      @logger.info("Where query returned document: test_users/#{first_result.document_id}")
    else
      raise "Where query did not return any documents"
    end
  end

  def test_update_document
    @logger.info("Testing document update")
    
    # Create a test document
    doc_id = test_create_document
    
    # Update the document
    @firestore.doc("test_users/#{doc_id}").update(
      status: "approved",
      updated_at: Time.now
    )
    
    # Get the updated document
    doc = @firestore.doc("test_users/#{doc_id}").get
    
    if doc.data[:status] == "approved"
      @logger.info("Document updated successfully: test_users/#{doc_id}")
    else
      raise "Failed to update document"
    end
  end

  def test_delete_document
    @logger.info("Testing document deletion")
    
    # Create a test document
    doc_id = test_create_document
    
    # Delete the document
    @firestore.doc("test_users/#{doc_id}").delete
    
    # Try to get the deleted document
    doc = @firestore.doc("test_users/#{doc_id}").get
    
    if !doc.exists?
      @logger.info("Document deleted successfully: test_users/#{doc_id}")
    else
      raise "Failed to delete document"
    end
  end

  def test_batch_operations
    @logger.info("Testing batch operations")
    
    # Create a batch
    batch = @firestore.batch
    
    # Add operations to the batch
    user_id1 = SecureRandom.uuid
    user_id2 = SecureRandom.uuid
    
    doc_ref1 = @firestore.doc("test_users/batch-test-1")
    doc_ref2 = @firestore.doc("test_users/batch-test-2")
    
    batch.set(doc_ref1, {
      uid: "batch-uid-1-#{user_id1}",
      email: "batch-1-#{user_id1}@example.com",
      display_name: "Batch User 1",
      role: "participant",
      status: "pending",
      created_at: Time.now,
      updated_at: Time.now
    })
    
    batch.set(doc_ref2, {
      uid: "batch-uid-2-#{user_id2}",
      email: "batch-2-#{user_id2}@example.com",
      display_name: "Batch User 2",
      role: "representative",
      status: "approved",
      created_at: Time.now,
      updated_at: Time.now
    })
    
    # Commit the batch
    batch.commit
    
    # Verify the documents were created
    doc1 = @firestore.doc("test_users/batch-test-1").get
    doc2 = @firestore.doc("test_users/batch-test-2").get
    
    if doc1.exists? && doc2.exists?
      @logger.info("Batch operation completed successfully")
    else
      raise "Failed to complete batch operation"
    end
  end

  def test_transaction
    @logger.info("Testing transactions")
    
    # Create a test document
    doc_id = test_create_document
    doc_ref = @firestore.doc("test_users/#{doc_id}")
    
    # Perform a transaction
    @firestore.transaction do |tx|
      # Read the document in the transaction
      doc = tx.get(doc_ref)
      
      # Update the document in the transaction
      tx.update(doc_ref, {
        role: "admin",
        updated_at: Time.now
      })
    end
    
    # Verify the document was updated
    doc = @firestore.doc("test_users/#{doc_id}").get
    
    if doc.data[:role] == "admin"
      @logger.info("Transaction completed successfully")
    else
      raise "Failed to complete transaction"
    end
  end

  def test_empty_query_handling
    @logger.info("Testing empty query handling")
    
    # Create a unique collection name to ensure it's empty
    empty_collection = "empty_collection_#{SecureRandom.hex(8)}"
    
    # Query the empty collection
    query = @firestore.col(empty_collection)
    docs = query.get
    
    # Test different ways to check if the query is empty
    
    # Method 1: Check if docs.first is nil
    first_doc = docs.first
    if first_doc.nil?
      @logger.info("Method 1 (first.nil?) correctly identified empty collection")
    else
      raise "Method 1 (first.nil?) failed to identify empty collection"
    end
    
    # Method 2: Check if any? returns false
    if !docs.any?
      @logger.info("Method 2 (!any?) correctly identified empty collection")
    else
      raise "Method 2 (!any?) failed to identify empty collection"
    end
    
    # Method 3: Count the documents (should be 0)
    count = 0
    docs.each { |_| count += 1 }
    
    if count == 0
      @logger.info("Method 3 (count == 0) correctly identified empty collection")
    else
      raise "Method 3 (count == 0) failed to identify empty collection"
    end
    
    @logger.info("Empty query handling tests passed")
  end
end

# Run the tests
logger.info("Starting Firebase Emulator tests")

begin
  tests = FirestoreTests.new(logger)
  success = tests.run_all_tests
  
  if success
    logger.info("All tests passed!")
    exit 0
  else
    logger.error("Tests failed!")
    exit 1
  end
rescue => e
  logger.error("Error running tests: #{e.message}")
  logger.error(e.backtrace.join("\n"))
  exit 1
end
