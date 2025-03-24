# Monkey patch Enumerator to add empty? method for Firestore compatibility
class Enumerator
  # Add empty? method to Enumerator to handle Firestore query results
  # This is needed because the Firebase emulator returns an Enumerator
  # that doesn't have the empty? method
  def empty?
    !self.first
  end
end

# Monkey patch Google::Cloud::Firestore::QuerySnapshot for additional safety
module Google
  module Cloud
    module Firestore
      class QuerySnapshot
        # Ensure the empty? method is properly defined
        def empty?
          !self.first
        end
      end
    end
  end
end

# Log that the patch has been applied
Rails.logger.info "Applied Firestore compatibility patches for query handling"
