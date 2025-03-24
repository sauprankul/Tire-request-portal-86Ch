Rails.application.config.middleware.use OmniAuth::Builder do
  # Use the Google OAuth credentials from environment variables
  provider :google_oauth2, 
           ENV.fetch('GOOGLE_CLIENT_ID', 'firebase-emulator-client-id'),
           ENV.fetch('GOOGLE_CLIENT_SECRET', 'firebase-emulator-client-secret'),
           {
             scope: 'email,profile',
             prompt: 'select_account',
             # Add additional options to help with debugging
             client_options: {
               ssl: { verify: false },  # Disable SSL verification in development
               site: 'https://accounts.google.com',
               authorize_url: 'https://accounts.google.com/o/oauth2/auth',
               token_url: 'https://accounts.google.com/o/oauth2/token'
             },
             # Explicitly set the callback URL
             redirect_uri: 'http://localhost:3000/auth/google_oauth2/callback',
             # Increase timeouts
             timeout: 60,
             open_timeout: 60
           }
  
  Rails.logger.info "OmniAuth configured with client ID: #{ENV.fetch('GOOGLE_CLIENT_ID', 'firebase-emulator-client-id')}"
  Rails.logger.info "OmniAuth configured with redirect URI: http://localhost:3000/auth/google_oauth2/callback"
end

# Allow both GET and POST requests for OmniAuth
OmniAuth.config.allowed_request_methods = [:get, :post]

# Add debugging for OmniAuth
OmniAuth.config.logger = Rails.logger

# Configure OmniAuth to handle failures
OmniAuth.config.on_failure = Proc.new do |env|
  Rails.logger.error "OmniAuth failure: #{env['omniauth.error']&.class} - #{env['omniauth.error']&.message}"
  Rails.logger.error "OmniAuth error strategy: #{env['omniauth.error.strategy']&.name}"
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
end
