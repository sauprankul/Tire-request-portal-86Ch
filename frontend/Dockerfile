FROM ruby:3.2.2

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    npm \
    postgresql-client

# Install Yarn
RUN npm install -g yarn

# Set working directory inside container
WORKDIR /rails_app

# Add debugging before bundle install
RUN echo "BEFORE BUNDLE INSTALL" && pwd && ls -la

# Copy Gemfile and install gems
COPY Gemfile ./
RUN touch Gemfile.lock
RUN echo "GEMFILE CONTENTS:" && cat Gemfile
RUN echo "RUBY VERSION BEFORE BUNDLE:" && ruby -v
RUN bundle install

# Note: We're not copying the application code here as we're using volume mounting

RUN echo "AFTER BUNDLE INSTALL:" && pwd && ls -la
RUN mkdir -p ./bin && touch ./bin/rails && chmod +x ./bin/rails

# Create a test script for logger
RUN echo 'puts "Testing logger loading:"\n\
require "logger"\n\
puts "Logger class loaded: #{Logger.name}"\n\
puts "Logger::Severity constants: #{Logger::Severity.constants}"\n\
' > /usr/local/bin/test_logger.rb

# Add a command to disable asset compilation during startup
RUN mkdir -p /rails_app/config/initializers
RUN echo 'Rails.application.config.assets.compile = false' > /rails_app/config/initializers/disable_asset_compilation.rb

# Precompile assets during build time
RUN mkdir -p /rails_app/app/assets/config
RUN echo '//= link_tree ../images\n//= link_directory ../javascripts .js\n//= link_directory ../stylesheets .css\n//= link application.js\n//= link application.css' > /rails_app/app/assets/config/manifest.js
RUN mkdir -p /rails_app/app/assets/stylesheets
RUN echo '/* Application styles */\nbody { font-family: Arial, sans-serif; }' > /rails_app/app/assets/stylesheets/application.css
RUN mkdir -p /rails_app/app/assets/javascripts
RUN echo '// This is a manifest file that will be compiled into application.js, which will include all the files\n// listed below.\n//\n// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,\n// or any plugin'\''s vendor/assets/javascripts directory can be referenced here using a relative path.\n//\n// It'\''s not advisable to add code directly here, but if you do, it'\''ll appear at the bottom of the\n// compiled file.\n//\n// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details\n// about supported directives.\n//\n//= require_tree .' > /rails_app/app/assets/javascripts/application.js
RUN mkdir -p /rails_app/app/javascript
RUN echo '// Entry point for the build script' > /rails_app/app/javascript/application.js

# Create startup script with all the original debugging and setup
RUN echo '#!/bin/bash\n\
set -e\n\
cd /rails_app\n\
echo "STARTING CONTAINER"\n\
pwd\n\
ls -la\n\
echo "CHECKING RUBY VERSION"\n\
ruby -v\n\
echo "CHECKING RAILS VERSION"\n\
bundle exec rails -v\n\
echo "TESTING LOGGER DIRECTLY"\n\
ruby /usr/local/bin/test_logger.rb\n\
echo "Rails.env: $RAILS_ENV"\n\
ls -la ./bin\n\
which rails\n\
echo "CHECKING FOR DATABASE.YML"\n\
if [ -f ./config/database.yml ]; then\n\
  echo "DATABASE.YML EXISTS:"\n\
  cat ./config/database.yml\n\
else\n\
  echo "DATABASE.YML MISSING"\n\
fi\n\
echo "CHECKING INITIALIZERS DIRECTORY"\n\
ls -la ./config/initializers/\n\
echo "CHECKING FOR MISSING RAILS FILES"\n\
if [ ! -f ./config/environment.rb ] || [ ! -f ./Rakefile ]; then\n\
  echo "Missing Rails files, generating Rails application structure"\n\
  cd /tmp\n\
  rails new temp_app --skip-git --skip-test --database=postgresql\n\
  cd /rails_app\n\
  mkdir -p /rails_app/config\n\
  cp -r /tmp/temp_app/config/environments /rails_app/config/\n\
  cp /tmp/temp_app/config/environment.rb /rails_app/config/\n\
  cp /tmp/temp_app/config/application.rb /rails_app/config/\n\
  cp /tmp/temp_app/config/boot.rb /rails_app/config/ 2>/dev/null || echo "No boot.rb file to copy"\n\
  cp /tmp/temp_app/Rakefile /rails_app/ 2>/dev/null || echo "No Rakefile to copy"\n\
  cp /tmp/temp_app/bin/rake /rails_app/bin/ 2>/dev/null || echo "No rake file to copy"\n\
  mkdir -p /rails_app/lib\n\
  cp -r /tmp/temp_app/lib /rails_app/\n\
  rm -rf /tmp/temp_app\n\
fi\n\
cd /rails_app\n\
echo "BEFORE CREATING AND MIGRATING DATABASE"\n\
pwd\n\
ls -la\n\
echo "CHECKING CONFIG DIRECTORY CONTENTS"\n\
ls -la ./config/\n\
echo "CHECKING FOR RAKEFILE"\n\
if [ ! -f ./Rakefile ]; then\n\
  echo "Creating minimal Rakefile"\n\
  echo "require_relative \"config/application\"\n\
Rails.application.load_tasks" > ./Rakefile\n\
fi\n\
echo "CREATING DATABASE.YML IF MISSING"\n\
if [ ! -f ./config/database.yml ]; then\n\
  echo "Creating database.yml"\n\
  mkdir -p ./config\n\
  echo "default: &default\n\
  adapter: postgresql\n\
  encoding: unicode\n\
  host: db\n\
  username: postgres\n\
  password: password\n\
  pool: 5\n\
\n\
development:\n\
  <<: *default\n\
  database: tire_request_portal_development\n\
\n\
test:\n\
  <<: *default\n\
  database: tire_request_portal_test\n\
\n\
production:\n\
  <<: *default\n\
  database: tire_request_portal_production" > ./config/database.yml\n\
fi\n\
echo "CHECKING FOR MANIFEST.JS"\n\
if [ ! -f ./app/assets/config/manifest.js ]; then\n\
  echo "manifest.js is missing, this should be in the repository"\n\
fi\n\
echo "CHECKING FOR APPLICATION.JS FILES"\n\
echo "In app/assets/javascripts:"\n\
ls -la ./app/assets/javascripts/ || echo "Directory not found"\n\
echo "In app/javascript:"\n\
ls -la ./app/javascript/ || echo "Directory not found"\n\
echo "CREATING AND MIGRATING DATABASE"\n\
cd /rails_app\n\
bundle check || bundle install\n\
echo "RUNNING RAKE DB:CREATE INSTEAD OF RAILS DB:CREATE"\n\
bundle exec rake db:create\n\
echo "RUNNING RAKE DB:MIGRATE"\n\
bundle exec rake db:migrate\n\
echo "UPDATING RAILS BINSTUBS"\n\
bundle exec rake app:update:bin\n\
echo "PRECOMPILING ASSETS"\n\
RAILS_ENV=development NODE_ENV=development bundle exec rake assets:precompile --trace\n\
echo "STARTING RAILS SERVER"\n\
mkdir -p /rails_app/tmp/pids\n\
bundle exec bin/rails server -b 0.0.0.0\n\
' > /usr/local/bin/start_rails.sh

RUN chmod +x /usr/local/bin/start_rails.sh /usr/local/bin/test_logger.rb

CMD ["/usr/local/bin/start_rails.sh"]
