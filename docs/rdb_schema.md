# PostgreSQL Database Schema

## Tables

### Users Table
```sql
-- Create enum types
CREATE TYPE user_role AS ENUM ('participant', 'representative', 'admin');
CREATE TYPE user_status AS ENUM ('pending', 'approved', 'rejected');

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  uid VARCHAR(255) UNIQUE NOT NULL,          -- Google Auth UID
  email VARCHAR(255) UNIQUE NOT NULL,        -- User's email address
  display_name VARCHAR(255) NOT NULL,        -- User's display name
  role user_role NOT NULL,                   -- User role enum
  status user_status NOT NULL,               -- User status enum
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Index for faster lookups
CREATE INDEX idx_users_uid ON users(uid);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_status ON users(status);
```

### Points Table
```sql
CREATE TABLE points (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  available INTEGER NOT NULL DEFAULT 0,      -- Available points
  pending INTEGER NOT NULL DEFAULT 0,        -- Pending points (in submitted requests)
  redeemed INTEGER NOT NULL DEFAULT 0,       -- Redeemed points
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  
  -- Ensure one points record per user
  CONSTRAINT unique_user_points UNIQUE (user_id)
);

-- Index for faster lookups
CREATE INDEX idx_points_user_id ON points(user_id);
```

### Products Table
```sql
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,                -- Product name
  description TEXT,                          -- Product description
  image_url TEXT,                            -- URL to product image
  price DECIMAL(10, 2) NOT NULL,             -- Price in dollars
  points_cost INTEGER NOT NULL,              -- Cost in points
  available BOOLEAN NOT NULL DEFAULT TRUE,   -- Whether the product is available
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Index for faster lookups
CREATE INDEX idx_products_available ON products(available);
```

### Requests Table
```sql
-- Create enum types
CREATE TYPE request_payment_type AS ENUM ('paypal', 'credit_card', 'points');
CREATE TYPE request_status AS ENUM ('SUBMITTED', 'AWAITING_PAYMENT', 'PAID', 'SHIPPED', 'RECEIVED', 'BACKORDERED', 'CANCELED');

CREATE TABLE requests (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
  quantity INTEGER NOT NULL,                 -- Number of tires requested
  payment_type request_payment_type NOT NULL, -- Payment type enum
  status request_status NOT NULL,            -- Request status enum
  assigned_rep_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
  payment_notes TEXT,                        -- PayPal link or credit card instructions
  tracking_number VARCHAR(255),              -- Shipping tracking number
  shipping_carrier VARCHAR(255),             -- Shipping carrier
  estimated_arrival TIMESTAMP,               -- Estimated arrival date
  shipped_date TIMESTAMP,                    -- When the order was shipped
  received_date TIMESTAMP,                   -- When the order was received
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes for faster lookups
CREATE INDEX idx_requests_user_id ON requests(user_id);
CREATE INDEX idx_requests_product_id ON requests(product_id);
CREATE INDEX idx_requests_assigned_rep_id ON requests(assigned_rep_id);
CREATE INDEX idx_requests_status ON requests(status);
CREATE INDEX idx_requests_payment_type ON requests(payment_type);
```

### Messages Table
```sql
CREATE TABLE messages (
  id SERIAL PRIMARY KEY,
  request_id INTEGER NOT NULL REFERENCES requests(id) ON DELETE CASCADE,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,                     -- Message content
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes for faster lookups
CREATE INDEX idx_messages_request_id ON messages(request_id);
CREATE INDEX idx_messages_user_id ON messages(user_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);
```

### Admin Emails Table
```sql
CREATE TABLE admin_emails (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,        -- Admin email address
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Index for faster lookups
CREATE INDEX idx_admin_emails_email ON admin_emails(email);
```

## Relationships

- Each user can have multiple requests (one-to-many)
- Each request belongs to one user and one product (many-to-one)
- Each request can have multiple messages (one-to-many)
- Each user can have one points record (one-to-one)
- Each request can be assigned to one representative (many-to-one)

## Migration Strategy

1. Create the PostgreSQL schema as defined above
2. Export data from Firestore to JSON
3. Transform the JSON data to match the PostgreSQL schema
4. Import the transformed data into PostgreSQL
5. Update the application code to use PostgreSQL instead of Firestore
6. Test the application thoroughly
7. Switch over to PostgreSQL in production

## Data Types Mapping

| Firestore Type | PostgreSQL Type |
|----------------|-----------------|
| string         | VARCHAR/TEXT    |
| number (int)   | INTEGER         |
| number (float) | DECIMAL/FLOAT   |
| boolean        | BOOLEAN         |
| timestamp      | TIMESTAMP       |
| map            | Separate table  |
| array          | Separate table  |
