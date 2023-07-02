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

ActiveRecord::Schema[7.0].define(version: 2022_06_06_093106) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "companies", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "company_code", null: false
    t.string "name", null: false
    t.boolean "disabled", default: false, null: false
    t.json "data"
    t.json "setting_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_code"], name: "index_companies_on_company_code", unique: true
  end

  create_table "group_users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.bigint "group_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "group_id"], name: "index_group_users_on_company_id_and_group_id"
    t.index ["company_id", "user_id"], name: "index_group_users_on_company_id_and_user_id"
    t.index ["company_id"], name: "index_group_users_on_company_id"
    t.index ["group_id"], name: "index_group_users_on_group_id"
    t.index ["user_id"], name: "index_group_users_on_user_id"
  end

  create_table "groups", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "name", null: false
    t.boolean "disabled", default: false, null: false
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_groups_on_company_id"
  end

  create_table "messages", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.integer "from_user_id", null: false
    t.integer "to_user_id"
    t.integer "group_id"
    t.json "data"
    t.boolean "read", default: false, null: false
    t.boolean "disabled", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "from_user_id", "group_id"], name: "index_messages_on_company_id_and_from_user_id_and_group_id"
    t.index ["company_id", "from_user_id", "to_user_id"], name: "index_messages_on_company_id_and_from_user_id_and_to_user_id"
    t.index ["company_id", "from_user_id"], name: "index_messages_on_company_id_and_from_user_id"
    t.index ["company_id", "group_id"], name: "index_messages_on_company_id_and_group_id"
    t.index ["company_id", "to_user_id"], name: "index_messages_on_company_id_and_to_user_id"
    t.index ["company_id"], name: "index_messages_on_company_id"
  end

  create_table "slips", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "name", null: false
    t.integer "status", null: false
    t.datetime "targeted_at", null: false
    t.integer "rep_user_id"
    t.integer "created_user_id", null: false
    t.integer "updated_user_id", null: false
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "created_user_id"], name: "index_slips_on_company_id_and_created_user_id"
    t.index ["company_id", "rep_user_id"], name: "index_slips_on_company_id_and_rep_user_id"
    t.index ["company_id", "status"], name: "index_slips_on_company_id_and_status"
    t.index ["company_id", "targeted_at"], name: "index_slips_on_company_id_and_targeted_at"
    t.index ["company_id", "updated_user_id"], name: "index_slips_on_company_id_and_updated_user_id"
    t.index ["company_id"], name: "index_slips_on_company_id"
    t.index ["status"], name: "index_slips_on_status"
    t.index ["targeted_at"], name: "index_slips_on_targeted_at"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "identifier", null: false
    t.string "password_digest", null: false
    t.string "authentication_token"
    t.datetime "authenticated_at"
    t.json "authentication_data"
    t.string "name", null: false
    t.integer "role", null: false
    t.geometry "position"
    t.boolean "disabled", default: false, null: false
    t.json "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "identifier"], name: "index_users_on_company_id_and_identifier", unique: true
    t.index ["company_id"], name: "index_users_on_company_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "group_users", "companies"
  add_foreign_key "group_users", "groups"
  add_foreign_key "group_users", "users"
  add_foreign_key "groups", "companies"
  add_foreign_key "messages", "companies"
  add_foreign_key "slips", "companies"
  add_foreign_key "users", "companies"
end
