# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_03_23_000000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "request_payment_type", ["paypal", "credit_card", "points"]
  create_enum "request_status", ["SUBMITTED", "AWAITING_PAYMENT", "PAID", "SHIPPED", "RECEIVED", "BACKORDERED", "CANCELED"]
  create_enum "user_role", ["participant", "representative", "admin"]
  create_enum "user_status", ["pending", "approved", "rejected"]

  create_table "admin_emails", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_emails_on_email", unique: true
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "request_id", null: false
    t.bigint "user_id", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["request_id"], name: "index_messages_on_request_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "points", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "available", default: 0, null: false
    t.integer "pending", default: 0, null: false
    t.integer "redeemed", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_points_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "image_url"
    t.decimal "price", precision: 10, scale: 2, null: false
    t.integer "points_cost", null: false
    t.boolean "available", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "requests", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", null: false
    t.enum "payment_type", null: false, enum_type: "request_payment_type"
    t.enum "status", default: "SUBMITTED", null: false, enum_type: "request_status"
    t.bigint "assigned_rep_id"
    t.text "payment_notes"
    t.string "tracking_number"
    t.string "shipping_carrier"
    t.date "estimated_arrival"
    t.datetime "shipped_date"
    t.datetime "received_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_rep_id"], name: "index_requests_on_assigned_rep_id"
    t.index ["product_id"], name: "index_requests_on_product_id"
    t.index ["user_id"], name: "index_requests_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "uid", null: false
    t.string "email", null: false
    t.string "display_name", null: false
    t.enum "role", default: "participant", enum_type: "user_role"
    t.enum "status", default: "pending", enum_type: "user_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

  add_foreign_key "messages", "requests"
  add_foreign_key "messages", "users"
  add_foreign_key "points", "users"
  add_foreign_key "requests", "products"
  add_foreign_key "requests", "users"
  add_foreign_key "requests", "users", column: "assigned_rep_id"
end
