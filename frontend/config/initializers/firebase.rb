require 'google/cloud/firestore'

# Load Firebase configuration
firebase_config = Rails.application.config_for(:firebase)

# Configure Firestore
if firebase_config['use_emulator']
  ENV['FIRESTORE_EMULATOR_HOST'] = "#{firebase_config['emulator_host']}:#{firebase_config['firestore_emulator_port']}"
end

# Initialize Firestore client
FIRESTORE = Google::Cloud::Firestore.new(
  project_id: firebase_config['project_id']
)

# Helper method to get a Firestore collection
def firestore_collection(collection_name)
  FIRESTORE.col(collection_name)
end

# Helper method to get a Firestore document
def firestore_document(collection_name, document_id)
  FIRESTORE.doc("#{collection_name}/#{document_id}")
end
