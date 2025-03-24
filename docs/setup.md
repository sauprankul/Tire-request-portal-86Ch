# Tire Request Portal Setup Guide

## Project Overview

The Tire Request Portal is a web application for managing tire requests for the 86 Challenge racing club. It allows participants to request tires, representatives to process those requests, and administrators to manage users and points.

### Key Features
- User authentication with Google Sign-In
- Role-based access control (Participant, Representative, Admin)
- Tire request submission and tracking
- Points system for tire redemption
- PostgreSQL database for data storage

## Prerequisites

### Ruby and Rails Installation (Windows)
1. Download and install Ruby using [RubyInstaller](https://rubyinstaller.org/downloads/) (with DevKit)
   - Choose Ruby+Devkit 3.3.X (x64)
   - During installation, check all options and run the ridk install
   
2. Install Rails:
   ```
   gem install rails -v 7.0.8
   ```

3. Install PostgreSQL:
   - Download from [PostgreSQL Downloads](https://www.postgresql.org/download/windows/)
   - Remember your superuser password during installation
   - Add PostgreSQL bin directory to your PATH

4. Install Node.js and Yarn:
   - Download Node.js from [nodejs.org](https://nodejs.org/)
   - Install Yarn: `npm install -g yarn`

5. Install Docker and Docker Compose (optional, for containerized setup):
   - Download Docker Desktop from [docker.com](https://www.docker.com/products/docker-desktop)
   - Enable WSL 2 if prompted

## Project Setup

### Option 1: Using Docker (Recommended)

1. Clone the repository:
   ```
   git clone https://github.com/sauprankul/Tire-request-portal-86Ch.git
   cd tire_request_portal
   ```

2. Set up environment variables:
   Create a `.env` file in the root directory with the following:
   ```
   GOOGLE_CLIENT_ID=your_google_client_id
   GOOGLE_CLIENT_SECRET=your_google_client_secret
   ```

3. Start the application using Docker Compose:
   ```
   docker-compose up -d
   ```

4. Access the application at http://localhost:3000

### Option 2: Manual Setup

1. Clone the repository:
   ```
   git clone https://github.com/sauprankul/Tire-request-portal-86Ch.git
   cd tire_request_portal
   ```

2. Install Ruby dependencies:
   ```
   cd frontend
   bundle install
   ```

3. Set up environment variables:
   Create a `.env` file in the frontend directory with the following:
   ```
   GOOGLE_CLIENT_ID=your_google_client_id
   GOOGLE_CLIENT_SECRET=your_google_client_secret
   ```

4. Create and set up the PostgreSQL database:
   ```
   rails db:create
   rails db:migrate
   ```

5. Start the Rails server:
   ```
   rails server
   ```

6. Access the application at http://localhost:3000

## Project Structure

### Rails Application
- `app/models`: Contains ActiveRecord model classes that interact with PostgreSQL
- `app/controllers`: Contains controllers for handling HTTP requests
- `app/views`: Contains view templates for rendering HTML
- `config`: Contains Rails configuration files
- `db/migrate`: Contains database migration files

## Development Workflow

1. Start the PostgreSQL database:
   ```
   # If using Docker
   docker-compose up -d db
   
   # If using local PostgreSQL
   # Ensure your PostgreSQL service is running
   ```

2. Run Rails server:
   ```
   # If using Docker
   docker-compose up -d web
   
   # If using local setup
   cd frontend
   rails server
   ```

3. Access the application at http://localhost:3000

## Initial Setup

When you first run the application, you'll need to:

1. Sign in with Google
2. The first user will automatically be assigned the Admin role
3. Use the Admin account to approve other users and assign roles

## Database Schema

The application uses PostgreSQL with the following key tables:
- `users`: Stores user information including role and status
- `points`: Tracks points for each user
- `products`: Contains tire product information
- `requests`: Stores tire requests with status tracking
- `messages`: Contains communications related to requests
- `admin_emails`: Stores pre-approved admin email addresses

The schema uses PostgreSQL enum types for better data integrity:
- `user_role`: 'participant', 'representative', 'admin'
- `user_status`: 'pending', 'approved', 'rejected'
- `request_payment_type`: 'paypal', 'credit_card', 'points'
- `request_status`: 'SUBMITTED', 'AWAITING_PAYMENT', 'PAID', 'SHIPPED', 'RECEIVED', 'BACKORDERED', 'CANCELED'

## Testing

To run the test suite:

```
cd frontend
rails test
```

## Deployment

### PostgreSQL Setup for Production

1. Set up a PostgreSQL database server (e.g., AWS RDS, Google Cloud SQL)
2. Create a database for the application
3. Update the database configuration in `frontend/config/database.yml`

### Rails Deployment

1. Set up your production database connection
2. Configure your production environment variables
3. Deploy the Rails application to your hosting provider

## Troubleshooting

### Common Issues

1. **Database Connection Issues**:
   - Ensure PostgreSQL is running and accessible
   - Check that the database credentials in `config/database.yml` are correct
   - Verify that the database exists and has been migrated

2. **Authentication Issues**:
   - Verify your Google OAuth credentials are correct
   - Check that the callback URL is properly configured in the Google Developer Console

3. **Asset Compilation Issues**:
   - Run `rails assets:precompile` if you're having issues with CSS or JavaScript
   - Check that application.js and application.css exist in the appropriate directories

For more help, please open an issue on the GitHub repository.
