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

  create_table "answers", force: :cascade do |t|
    t.uuid "survey_id", null: false
    t.uuid "reply_id", null: false
    t.uuid "question_id", null: false
    t.bigint "question_type_id"
    t.bigint "question_option_id"
    t.string "short_text_value"
    t.text "long_text_value"
    t.integer "number_value"
    t.decimal "float_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["float_value"], name: "index_answers_on_float_value"
    t.index ["long_text_value"], name: "index_answers_on_long_text_value"
    t.index ["number_value"], name: "index_answers_on_number_value"
    t.index ["question_id"], name: "index_answers_on_question_id"
    t.index ["question_option_id"], name: "index_answers_on_question_option_id"
    t.index ["question_type_id"], name: "index_answers_on_question_type_id"
    t.index ["reply_id"], name: "index_answers_on_reply_id"
    t.index ["short_text_value"], name: "index_answers_on_short_text_value"
    t.index ["survey_id"], name: "index_answers_on_survey_id"
  end

  create_table "question_options", force: :cascade do |t|
    t.uuid "question_id", null: false
    t.string "text", null: false
    t.integer "weight", null: false
    t.integer "display_order", default: 0, null: false
    t.uuid "followup_question_id"
    t.index ["followup_question_id"], name: "index_question_options_on_followup_question_id"
    t.index ["question_id"], name: "index_question_options_on_question_id"
    t.index ["text"], name: "index_question_options_on_text"
    t.index ["weight"], name: "index_question_options_on_weight"
  end

  create_table "question_types", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.boolean "countable", default: false, null: false
    t.index ["countable"], name: "index_question_types_on_countable"
    t.index ["name"], name: "index_question_types_on_name"
    t.index ["slug"], name: "index_question_types_on_slug"
  end

  create_table "questions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "text", null: false
    t.bigint "hash_code", null: false
    t.string "type"
    t.integer "display_order", default: 0, null: false
    t.boolean "required", default: false, null: false
    t.bigint "question_type_id", null: false
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
    t.index ["submitted"], name: "index_replies_on_submitted"
    t.index ["survey_id"], name: "index_replies_on_survey_id"
  end

  create_table "surveys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "description"
    t.bigint "author_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_surveys_on_author_id"
    t.index ["created_at"], name: "index_surveys_on_created_at"
    t.index ["name"], name: "index_surveys_on_name"
    t.index ["slug"], name: "index_surveys_on_slug"
    t.index ["updated_at"], name: "index_surveys_on_updated_at"
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

  add_foreign_key "question_options", "questions", column: "followup_question_id"
  add_foreign_key "surveys", "users", column: "author_id", on_delete: :cascade
end
