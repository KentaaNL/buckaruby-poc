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

ActiveRecord::Schema.define(version: 20160908064622) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "payments", force: :cascade do |t|
    t.decimal  "amount",               precision: 8, scale: 2,                  null: false
    t.string   "description"
    t.string   "transaction_id"
    t.string   "payment_id"
    t.string   "payment_method"
    t.string   "payment_issuer"
    t.string   "payment_account_name"
    t.string   "payment_account_iban"
    t.integer  "status"
    t.datetime "started_at"
    t.datetime "paid_at"
    t.datetime "cancelled_at"
    t.datetime "failed_at"
    t.datetime "charged_back_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mode",                                         default: "test", null: false
    t.boolean  "recurring",                                    default: false,  null: false
    t.boolean  "recurrent",                                    default: false,  null: false
  end

end
