# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140602222629) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "donations", force: true do |t|
    t.decimal  "amount",         precision: 8, scale: 2
    t.integer  "user_id"
    t.text     "comments"
    t.text     "internal_notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "payment_id"
  end

  add_index "donations", ["payment_id"], name: "index_donations_on_payment_id", using: :btree
  add_index "donations", ["user_id"], name: "index_donations_on_user_id", using: :btree

  create_table "payments", force: true do |t|
    t.string   "public_id"
    t.decimal  "amount",           precision: 8, scale: 2
    t.hstore   "web_request"
    t.hstore   "merchant_details"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.decimal  "price",              precision: 8, scale: 2
    t.integer  "quantity"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_line_items", force: true do |t|
    t.integer  "quantity"
    t.decimal  "unit_price",  precision: 8, scale: 2
    t.integer  "purchase_id"
    t.integer  "product_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "purchase_line_items", ["product_id"], name: "index_purchase_line_items_on_product_id", using: :btree
  add_index "purchase_line_items", ["purchase_id"], name: "index_purchase_line_items_on_purchase_id", using: :btree

  create_table "purchases", force: true do |t|
    t.decimal  "price",            precision: 8, scale: 2
    t.hstore   "item_details"
    t.text     "shipping_address"
    t.text     "comments"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "purchases", ["user_id"], name: "index_purchases_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",            null: false
    t.string   "crypted_password", null: false
    t.string   "salt",             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "roles"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
