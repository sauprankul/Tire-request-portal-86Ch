# Tire Request Portal Setup Guide

## Project Overview

The Tire Request Portal is a web application for managing tire requests for the 86 Challenge racing club. It allows participants to request tires, representatives to process those requests, and administrators to manage users and points.

### Key Features
- User authentication with Google Sign-In
- Role-based access control (Participant, Representative, Admin)
- Tire request submission and tracking
- Points system for tire redemption
- Real-time updates using Firebase

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

### Firebase Setup
1. Install Firebase CLI:
   ```
   npm install -g firebase-tools
   ```

2. Login to Firebase:
   ```
   firebase login
   ```

3. Initialize Firebase Emulator Suite:
   ```
   cd backend/firebase
   firebase init emulators
   ```
   - Select Authentication, Firestore, and Functions
   - Choose default ports or specify your own

## Project Setup

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

4. Start the Firebase emulators:
   ```
   cd ../backend/firebase
   firebase emulators:start
   ```

5. Start the Rails server (in a new terminal):
   ```
   cd frontend
   rails server
   ```

6. Access the application at http://localhost:3000

## Project Structure

### Frontend (Rails Application)
- `app/models`: Contains model classes that interact with Firestore
- `app/controllers`: Contains controllers for handling HTTP requests
- `app/views`: Contains view templates for rendering HTML
- `config`: Contains Rails configuration files

### Backend (Firebase)
- `firebase.json`: Firebase configuration file
- `firestore.rules`: Security rules for Firestore
- `firestore.indexes.json`: Indexes for Firestore queries
- `functions`: Cloud Functions for Firebase

## Development Workflow

1. Run Firebase emulators in one terminal:
   ```
   cd backend/firebase
   firebase emulators:start
   ```

2. Run Rails server in another terminal:
   ```
   cd frontend
   rails server
   ```

3. Access the application at http://localhost:3000

## Initial Setup

When you first run the application, you'll need to:

1. Sign in with Google
2. The first user will automatically be assigned the Admin role
3. Use the Admin account to approve other users and assign roles

## Testing

To run the test suite:

```
cd frontend
rails test
```

## Deployment

### Firebase Setup for Production

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication with Google as a provider
3. Enable Firestore Database
4. Update the Firebase configuration in `frontend/config/firebase.yml`

### Rails Deployment

1. Set up your production database
2. Configure your production environment variables
3. Deploy the Rails application to your hosting provider

## Troubleshooting

### Common Issues

1. **Firebase Emulator Connection Issues**:
   - Ensure the emulators are running before starting the Rails server
   - Check that the ports in `frontend/config/firebase.yml` match your emulator ports

2. **Authentication Issues**:
   - Verify your Google OAuth credentials are correct
   - Check that the callback URL is properly configured in the Google Developer Console

3. **Database Issues**:
   - Make sure Firestore emulator is running
   - Check Firestore rules if you're getting permission errors

For more help, please open an issue on the GitHub repository.
