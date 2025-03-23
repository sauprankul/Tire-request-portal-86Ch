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
COPY Gemfile Gemfile.lock ./

RUN echo "GEMFILE CONTENTS:" && cat Gemfile
RUN echo "RUBY VERSION BEFORE BUNDLE:" && ruby -v
RUN bundle install

# Copy rest of the application code
COPY . .

RUN echo "AFTER COPYING ALL FILES:" && pwd && ls -la
RUN chmod +x ./bin/rails

# Create a test script for logger
RUN echo 'puts "Testing logger loading:"\n\
require "logger"\n\
puts "Logger class loaded: #{Logger.name}"\n\
puts "Logger::Severity constants: #{Logger::Severity.constants}"\n\
' > /usr/local/bin/test_logger.rb

# Create a startup script with debugging commands
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
echo "CREATING AND MIGRATING DATABASE"\n\
cd /rails_app\n\
bundle check || bundle install\n\
echo "RUNNING RAKE DB:CREATE INSTEAD OF RAILS DB:CREATE"\n\
cd /rails_app && bundle exec rake db:create\n\
echo "RUNNING RAKE DB:MIGRATE"\n\
cd /rails_app && bundle exec rake db:migrate\n\
echo "STARTING RAILS SERVER"\n\
cd /rails_app && bundle exec rails server -b 0.0.0.0\n\
' > /usr/local/bin/start_rails.sh

RUN chmod +x /usr/local/bin/start_rails.sh /usr/local/bin/test_logger.rb

CMD ["/usr/local/bin/start_rails.sh"]
