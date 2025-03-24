class CreatePostgresqlTables < ActiveRecord::Migration[7.0]
  def change
    # Create enum types
    execute <<-SQL
      CREATE TYPE user_role AS ENUM ('participant', 'representative', 'admin');
      CREATE TYPE user_status AS ENUM ('pending', 'approved', 'rejected');
      CREATE TYPE request_payment_type AS ENUM ('paypal', 'credit_card', 'points');
      CREATE TYPE request_status AS ENUM ('SUBMITTED', 'AWAITING_PAYMENT', 'PAID', 'SHIPPED', 'RECEIVED', 'BACKORDERED', 'CANCELED');
    SQL

    # Create users table
    create_table :users do |t|
      t.string :uid, null: false, index: { unique: true }
      t.string :email, null: false, index: { unique: true }
      t.string :display_name, null: false
      t.column :role, :user_role, default: 'participant'
      t.column :status, :user_status, default: 'pending'
      t.timestamps
    end

    # Create points table
    create_table :points do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :available, default: 0, null: false
      t.integer :pending, default: 0, null: false
      t.integer :redeemed, default: 0, null: false
      t.timestamps
    end

    # Create products table
    create_table :products do |t|
      t.string :name, null: false
      t.text :description
      t.string :image_url
      t.decimal :price, precision: 10, scale: 2, null: false
      t.integer :points_cost, null: false
      t.boolean :available, default: true
      t.timestamps
    end

    # Create requests table
    create_table :requests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.column :payment_type, :request_payment_type, null: false
      t.column :status, :request_status, default: 'SUBMITTED', null: false
      t.references :assigned_rep, foreign_key: { to_table: :users }
      t.text :payment_notes
      t.string :tracking_number
      t.string :shipping_carrier
      t.date :estimated_arrival
      t.datetime :shipped_date
      t.datetime :received_date
      t.timestamps
    end

    # Create messages table
    create_table :messages do |t|
      t.references :request, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :content, null: false
      t.timestamps
    end

    # Create admin_emails table
    create_table :admin_emails do |t|
      t.string :email, null: false, index: { unique: true }
      t.timestamps
    end
  end

  def down
    drop_table :messages
    drop_table :requests
    drop_table :products
    drop_table :points
    drop_table :admin_emails
    drop_table :users

    execute <<-SQL
      DROP TYPE IF EXISTS request_status;
      DROP TYPE IF EXISTS request_payment_type;
      DROP TYPE IF EXISTS user_status;
      DROP TYPE IF EXISTS user_role;
    SQL
  end
end
