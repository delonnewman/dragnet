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

ActiveRecord::Schema[7.0].define(version: 2023_07_07_221532) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ahoy_events", force: :cascade do |t|
    t.bigint "visit_id"
    t.bigint "user_id"
    t.string "name"
    t.jsonb "properties"
    t.datetime "time"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["properties"], name: "index_ahoy_events_on_properties", opclass: :jsonb_path_ops, using: :gin
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", force: :cascade do |t|
    t.string "visit_token"
    t.string "visitor_token"
    t.bigint "user_id"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.string "referring_domain"
    t.text "landing_page"
    t.string "browser"
    t.string "os"
    t.string "device_type"
    t.string "country"
    t.string "region"
    t.string "city"
    t.float "latitude"
    t.float "longitude"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.string "app_version"
    t.string "os_version"
    t.string "platform"
    t.datetime "started_at"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
  end

  create_table "answers", force: :cascade do |t|
    t.uuid "survey_id", null: false
    t.uuid "reply_id", null: false
    t.uuid "question_id", null: false
    t.uuid "question_type_id"
    t.bigint "question_option_id"
    t.string "short_text_value"
    t.text "long_text_value"
    t.integer "integer_value"
    t.boolean "boolean_value"
    t.decimal "float_value"
    t.time "time_value"
    t.date "date_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["boolean_value"], name: "index_answers_on_boolean_value"
    t.index ["date_value"], name: "index_answers_on_date_value"
    t.index ["float_value"], name: "index_answers_on_float_value"
    t.index ["integer_value"], name: "index_answers_on_integer_value"
    t.index ["long_text_value"], name: "index_answers_on_long_text_value"
    t.index ["question_id"], name: "index_answers_on_question_id"
    t.index ["question_option_id"], name: "index_answers_on_question_option_id"
    t.index ["question_type_id"], name: "index_answers_on_question_type_id"
    t.index ["reply_id"], name: "index_answers_on_reply_id"
    t.index ["short_text_value"], name: "index_answers_on_short_text_value"
    t.index ["survey_id"], name: "index_answers_on_survey_id"
    t.index ["time_value"], name: "index_answers_on_time_value"
  end

  create_table "meta_data", force: :cascade do |t|
    t.string "self_describable_type"
    t.uuid "self_describable_id"
    t.string "key", null: false
    t.string "key_type", default: "String", null: false
    t.string "value", null: false
    t.index ["key"], name: "index_meta_data_on_key"
    t.index ["key_type"], name: "index_meta_data_on_key_type"
    t.index ["self_describable_type", "self_describable_id"], name: "index_meta_data_on_self_describable"
    t.index ["value"], name: "index_meta_data_on_value"
  end

  create_table "question_options", force: :cascade do |t|
    t.uuid "question_id", null: false
    t.string "text", null: false
    t.integer "weight"
    t.integer "display_order", default: 0, null: false
    t.uuid "followup_question_id"
    t.index ["followup_question_id"], name: "index_question_options_on_followup_question_id"
    t.index ["question_id"], name: "index_question_options_on_question_id"
    t.index ["text"], name: "index_question_options_on_text"
    t.index ["weight"], name: "index_question_options_on_weight"
  end

  create_table "question_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "icon"
    t.uuid "parent_type_id"
    t.index ["name"], name: "index_question_types_on_name"
    t.index ["parent_type_id"], name: "index_question_types_on_parent_type_id"
    t.index ["slug"], name: "index_question_types_on_slug"
  end

  create_table "questions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "text", null: false
    t.bigint "hash_code", null: false
    t.string "type"
    t.integer "display_order", default: 0, null: false
    t.boolean "required", default: false, null: false
    t.uuid "question_type_id", null: false
    t.uuid "survey_id", null: false
    t.uuid "question_id"
    t.bigint "question_option_id"
    t.index ["hash_code"], name: "index_questions_on_hash_code"
    t.index ["question_id"], name: "index_questions_on_question_id"
    t.index ["question_option_id"], name: "index_questions_on_question_option_id"
    t.index ["question_type_id"], name: "index_questions_on_question_type_id"
    t.index ["survey_id"], name: "index_questions_on_survey_id"
    t.index ["type"], name: "index_questions_on_type"
  end

  create_table "replies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "survey_id", null: false
    t.string "answer_records"
    t.boolean "submitted", default: false, null: false
    t.datetime "submitted_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "ahoy_visit_id"
    t.index ["ahoy_visit_id"], name: "index_replies_on_ahoy_visit_id"
    t.index ["submitted"], name: "index_replies_on_submitted"
    t.index ["survey_id"], name: "index_replies_on_survey_id"
  end

  create_table "saved_reports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "author_id", null: false
    t.string "name", null: false
    t.string "question_ids", null: false
    t.string "filters"
    t.string "sort_by"
    t.string "sort_direction"
    t.index ["author_id"], name: "index_saved_reports_on_author_id"
  end

  create_table "survey_edits", force: :cascade do |t|
    t.uuid "survey_id", null: false
    t.binary "survey_data"
    t.boolean "applied", default: false, null: false
    t.datetime "applied_at", precision: nil
    t.datetime "created_at", precision: nil
    t.index ["applied"], name: "index_survey_edits_on_applied"
    t.index ["applied_at"], name: "index_survey_edits_on_applied_at"
    t.index ["created_at"], name: "index_survey_edits_on_created_at"
    t.index ["survey_id"], name: "index_survey_edits_on_survey_id"
  end

  create_table "surveys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "description"
    t.string "type"
    t.bigint "author_id", null: false
    t.uuid "copy_of_id"
    t.integer "edits_status"
    t.boolean "open", default: false, null: false
    t.boolean "public", default: false, null: false
    t.datetime "latest_submission_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_surveys_on_author_id"
    t.index ["copy_of_id"], name: "index_surveys_on_copy_of_id"
    t.index ["created_at"], name: "index_surveys_on_created_at"
    t.index ["edits_status"], name: "index_surveys_on_edits_status"
    t.index ["latest_submission_at"], name: "index_surveys_on_latest_submission_at"
    t.index ["name", "author_id"], name: "index_surveys_on_name_and_author_id", unique: true
    t.index ["name"], name: "index_surveys_on_name"
    t.index ["open"], name: "index_surveys_on_open"
    t.index ["public"], name: "index_surveys_on_public"
    t.index ["slug"], name: "index_surveys_on_slug"
    t.index ["type"], name: "index_surveys_on_type"
    t.index ["updated_at"], name: "index_surveys_on_updated_at"
  end

  create_table "trigger_registrations", force: :cascade do |t|
    t.uuid "survey_id", null: false
    t.string "trigger_class_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["survey_id"], name: "index_trigger_registrations_on_survey_id"
    t.index ["trigger_class_name"], name: "index_trigger_registrations_on_trigger_class_name"
  end

  create_table "users", force: :cascade do |t|
    t.string "login", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "nickname"
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["created_at"], name: "index_users_on_created_at"
    t.index ["email"], name: "index_users_on_email"
    t.index ["login"], name: "index_users_on_login"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["updated_at"], name: "index_users_on_updated_at"
  end

  add_foreign_key "question_options", "questions", column: "followup_question_id"
  add_foreign_key "question_options", "questions", on_delete: :cascade
  add_foreign_key "questions", "surveys", on_delete: :cascade
  add_foreign_key "saved_reports", "users", column: "author_id", on_delete: :cascade
  add_foreign_key "surveys", "users", column: "author_id", on_delete: :cascade
end
