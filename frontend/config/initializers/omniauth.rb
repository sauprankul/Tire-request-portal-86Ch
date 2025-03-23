Rails.application.config.middleware.use OmniAuth::Builder do
  # In production, you would use actual Google OAuth credentials
  # For development with Firebase emulator, we use a placeholder
  provider :google_oauth2, 
           ENV.fetch('GOOGLE_CLIENT_ID', 'firebase-emulator-client-id'),
           ENV.fetch('GOOGLE_CLIENT_SECRET', 'firebase-emulator-client-secret'),
           {
             scope: 'email,profile',
             prompt: 'select_account'
           }
end

# Protect from CSRF attacks
OmniAuth.config.allowed_request_methods = [:post]
