-- Create enum types
CREATE TYPE user_role AS ENUM ('participant', 'representative', 'admin');
CREATE TYPE user_status AS ENUM ('pending', 'approved', 'rejected');
CREATE TYPE request_payment_type AS ENUM ('paypal', 'credit_card', 'points');
CREATE TYPE request_status AS ENUM ('SUBMITTED', 'AWAITING_PAYMENT', 'PAID', 'SHIPPED', 'RECEIVED', 'BACKORDERED', 'CANCELED');

-- Create Users table
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  uid VARCHAR(255) NOT NULL UNIQUE,
  email VARCHAR(255) NOT NULL UNIQUE,
  display_name VARCHAR(255) NOT NULL,
  role user_role NOT NULL,
  status user_status NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create Points table
CREATE TABLE points (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  available INTEGER NOT NULL DEFAULT 0,
  pending INTEGER NOT NULL DEFAULT 0,
  redeemed INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id)
);

-- Create Products table
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  image_url TEXT,
  price DECIMAL(10, 2) NOT NULL,
  points_cost INTEGER NOT NULL,
  available BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_products_available ON products(available);

-- Create Requests table
CREATE TABLE requests (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
  quantity INTEGER NOT NULL,
  payment_type request_payment_type NOT NULL,
  status request_status NOT NULL,
  assigned_rep_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
  payment_notes TEXT,
  tracking_number VARCHAR(255),
  shipping_carrier VARCHAR(255),
  estimated_arrival TIMESTAMP,
  shipped_date TIMESTAMP,
  received_date TIMESTAMP,
  shipping_name VARCHAR(255),
  shipping_phone VARCHAR(255),
  shipping_address VARCHAR(255),
  shipping_city VARCHAR(255),
  shipping_state VARCHAR(255),
  shipping_zip VARCHAR(255),
  notes TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_requests_user_id ON requests(user_id);
CREATE INDEX idx_requests_product_id ON requests(product_id);
CREATE INDEX idx_requests_payment_type ON requests(payment_type);
CREATE INDEX idx_requests_status ON requests(status);
CREATE INDEX idx_requests_assigned_rep_id ON requests(assigned_rep_id);

-- Create Messages table
CREATE TABLE messages (
  id SERIAL PRIMARY KEY,
  request_id INTEGER NOT NULL REFERENCES requests(id) ON DELETE CASCADE,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_messages_request_id ON messages(request_id);
CREATE INDEX idx_messages_user_id ON messages(user_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);

-- Create AdminEmails table
CREATE TABLE admin_emails (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
