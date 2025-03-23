# Firestore Database Schema

## Collections and Documents

### Users Collection
```
users/{userId}
{
  uid: string,             // Firebase Auth UID
  email: string,           // User's email address
  display_name: string,    // User's display name
  role: string,            // 'participant', 'representative', or 'admin'
  status: string,          // 'pending', 'approved', or 'rejected'
  created_at: timestamp,   // When the user was created
  updated_at: timestamp    // When the user was last updated
}
```

### Points Collection
```
points/{userId}
{
  user_id: string,         // Reference to users/{userId}
  available: number,       // Available points
  pending: number,         // Pending points (in submitted requests)
  redeemed: number,        // Redeemed points
  created_at: timestamp,   // When the points record was created
  updated_at: timestamp    // When the points record was last updated
}
```

### Products Collection
```
products/{productId}
{
  name: string,            // Product name
  description: string,     // Product description
  image_url: string,       // URL to product image
  price: number,           // Price in dollars
  points_cost: number,     // Cost in points (typically 4 points = 1 tire)
  available: boolean,      // Whether the product is available
  created_at: timestamp,   // When the product was created
  updated_at: timestamp    // When the product was last updated
}
```

### Requests Collection
```
requests/{requestId}
{
  user_id: string,         // Reference to users/{userId}
  product_id: string,      // Reference to products/{productId}
  quantity: number,        // Number of tires requested (1-10)
  payment_type: string,    // 'paypal', 'credit_card', or 'points'
  status: string,          // 'SUBMITTED', 'AWAITING_PAYMENT', 'PAID', 'SHIPPED', 'RECEIVED', 'BACKORDERED', 'CANCELED'
  assigned_rep_id: string, // Reference to users/{userId} of the representative
  payment_notes: string,   // PayPal link or credit card instructions
  tracking_number: string, // Shipping tracking number
  shipping_carrier: string,// Shipping carrier
  estimated_arrival: timestamp, // Estimated arrival date
  shipped_date: timestamp, // When the order was shipped
  received_date: timestamp,// When the order was received
  created_at: timestamp,   // When the request was created
  updated_at: timestamp    // When the request was last updated
}
```

### Messages Subcollection
```
requests/{requestId}/messages/{messageId}
{
  request_id: string,      // Reference to requests/{requestId}
  user_id: string,         // Reference to users/{userId} who sent the message
  content: string,         // Message content
  created_at: timestamp    // When the message was created
}
```

### Admin Emails Collection
```
admin_emails/{emailId}
{
  email: string,           // Admin email address
  created_at: timestamp    // When the admin email was added
}
```

## Relationships

- Each user can have multiple requests
- Each request belongs to one user and one product
- Each request can have multiple messages
- Each user can have one points record
- Each request can be assigned to one representative
