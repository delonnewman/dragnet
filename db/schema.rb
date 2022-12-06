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

ActiveRecord::Schema[7.0].define(version: 2022_05_14_023941) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "field_options", force: :cascade do |t|
    t.uuid "field_id", null: false
    t.string "text", null: false
    t.integer "weight"
    t.integer "display_order", default: 0, null: false
    t.uuid "dependent_field_id"
    t.index ["dependent_field_id"], name: "index_field_options_on_dependent_field_id"
    t.index ["field_id"], name: "index_field_options_on_field_id"
    t.index ["text"], name: "index_field_options_on_text"
    t.index ["weight"], name: "index_field_options_on_weight"
  end

  create_table "field_types", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "icon"
    t.string "settings"
    t.bigint "parent_type_id"
    t.index ["name"], name: "index_field_types_on_name"
    t.index ["parent_type_id"], name: "index_field_types_on_parent_type_id"
    t.index ["slug"], name: "index_field_types_on_slug"
  end

  create_table "fields", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "text", null: false
    t.bigint "hash_code", null: false
    t.string "type"
    t.integer "display_order", default: 0, null: false
    t.boolean "required", default: false, null: false
    t.bigint "field_type_id", null: false
    t.uuid "form_id", null: false
    t.string "settings"
    t.uuid "dependent_field_id"
    t.bigint "field_option_id"
    t.index ["dependent_field_id"], name: "index_fields_on_dependent_field_id"
    t.index ["field_option_id"], name: "index_fields_on_field_option_id"
    t.index ["field_type_id"], name: "index_fields_on_field_type_id"
    t.index ["form_id"], name: "index_fields_on_form_id"
    t.index ["hash_code"], name: "index_fields_on_hash_code"
    t.index ["type"], name: "index_fields_on_type"
  end

  create_table "form_edits", force: :cascade do |t|
    t.uuid "form_id", null: false
    t.binary "form_data"
    t.boolean "applied", default: false, null: false
    t.datetime "applied_at", precision: nil
    t.datetime "created_at", precision: nil
    t.index ["applied"], name: "index_form_edits_on_applied"
    t.index ["applied_at"], name: "index_form_edits_on_applied_at"
    t.index ["created_at"], name: "index_form_edits_on_created_at"
    t.index ["form_id"], name: "index_form_edits_on_form_id"
  end

  create_table "forms", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "description"
    t.bigint "author_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_forms_on_author_id"
    t.index ["created_at"], name: "index_forms_on_created_at"
    t.index ["name"], name: "index_forms_on_name"
    t.index ["slug"], name: "index_forms_on_slug"
    t.index ["updated_at"], name: "index_forms_on_updated_at"
  end

  create_table "response_items", force: :cascade do |t|
    t.uuid "form_id", null: false
    t.uuid "response_id", null: false
    t.uuid "field_id", null: false
    t.bigint "field_type_id"
    t.bigint "field_option_id"
    t.string "short_text_value"
    t.text "long_text_value"
    t.integer "number_value"
    t.decimal "float_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["field_id"], name: "index_response_items_on_field_id"
    t.index ["field_option_id"], name: "index_response_items_on_field_option_id"
    t.index ["field_type_id"], name: "index_response_items_on_field_type_id"
    t.index ["float_value"], name: "index_response_items_on_float_value"
    t.index ["form_id"], name: "index_response_items_on_form_id"
    t.index ["long_text_value"], name: "index_response_items_on_long_text_value"
    t.index ["number_value"], name: "index_response_items_on_number_value"
    t.index ["response_id"], name: "index_response_items_on_response_id"
    t.index ["short_text_value"], name: "index_response_items_on_short_text_value"
  end

  create_table "responses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "form_id", null: false
    t.string "response_item_cache"
    t.boolean "submitted", default: false, null: false
    t.datetime "submitted_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["form_id"], name: "index_responses_on_form_id"
    t.index ["submitted"], name: "index_responses_on_submitted"
  end

  create_table "users", force: :cascade do |t|
    t.string "login", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "nickname"
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_users_on_created_at"
    t.index ["email"], name: "index_users_on_email"
    t.index ["login"], name: "index_users_on_login"
    t.index ["updated_at"], name: "index_users_on_updated_at"
  end

  add_foreign_key "field_options", "fields", column: "dependent_field_id"
  add_foreign_key "field_options", "fields", on_delete: :cascade
  add_foreign_key "fields", "forms", on_delete: :cascade
  add_foreign_key "forms", "users", column: "author_id", on_delete: :cascade
end
