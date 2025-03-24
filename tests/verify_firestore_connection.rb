#!/usr/bin/env ruby
# Verify Firestore Connection
# This script tests the connection to the Firestore emulator and performs basic operations

require 'google/cloud/firestore'
require 'logger'

# Set up logger
logger = Logger.new(STDOUT)
logger.level = Logger::INFO
logger.formatter = proc do |severity, datetime, progname, msg|
  "#{datetime.strftime('%Y-%m-%d %H:%M:%S')} [#{severity}] #{msg}\n"
end

logger.info("Starting Firestore connection test")
logger.info("FIRESTORE_EMULATOR_HOST: #{ENV['FIRESTORE_EMULATOR_HOST']}")

begin
  # Connect to Firestore
  firestore = Google::Cloud::Firestore.new(
    project_id: "tire-request-portal"
    # No need to specify emulator_host, it will use the FIRESTORE_EMULATOR_HOST env variable
  )
  
  logger.info("Connected to Firestore emulator")
  
  # Test collection access
  test_collection = firestore.col("test_connection")
  logger.info("Accessed test_connection collection")
  
  # Test document creation
  test_doc_id = "test_#{Time.now.to_i}"
  test_doc_ref = test_collection.doc(test_doc_id)
  test_doc_ref.set({
    timestamp: Time.now,
    message: "Connection test successful"
  })
  logger.info("Created test document with ID: #{test_doc_id}")
  
  # Test document retrieval
  test_doc = test_doc_ref.get
  if test_doc.exists?
    logger.info("Retrieved test document successfully")
    logger.info("Document data: #{test_doc.data}")
  else
    logger.error("Failed to retrieve test document")
  end
  
  # Test direct document access
  user_id = "101432360857454882761"
  user_doc_ref = firestore.doc("users/#{user_id}")
  user_doc = user_doc_ref.get
  
  if user_doc.exists?
    logger.info("Found user document with ID: #{user_id}")
    logger.info("User data: #{user_doc.data}")
  else
    logger.warn("User document not found with ID: #{user_id}")
    
    # Try to create the user document
    logger.info("Creating user document with ID: #{user_id}")
    user_doc_ref.set({
      uid: user_id,
      email: "saurabh.kulkarni997@gmail.com",
      display_name: "Admin User",
      role: "admin",
      status: "approved",
      created_at: Time.now,
      updated_at: Time.now
    })
    
    # Verify creation
    user_doc = user_doc_ref.get
    if user_doc.exists?
      logger.info("Created user document successfully")
      logger.info("User data: #{user_doc.data}")
    else
      logger.error("Failed to create user document")
    end
  end
  
  # Test query
  logger.info("Testing query for users collection")
  users_query = firestore.col("users").where("uid", "==", user_id).limit(1)
  
  begin
    users_docs = users_query.get
    first_doc = users_docs.first
    
    if first_doc.nil?
      logger.warn("No user found with query")
    else
      logger.info("Found user with query")
      logger.info("User data from query: #{first_doc.data}")
    end
  rescue => e
    logger.error("Error executing query: #{e.message}")
    logger.error(e.backtrace.join("\n"))
  end
  
  logger.info("Firestore connection test completed successfully")
  exit 0
rescue => e
  logger.error("ERROR: #{e.class.name}: #{e.message}")
  logger.error(e.backtrace.join("\n"))
  exit 1
end
