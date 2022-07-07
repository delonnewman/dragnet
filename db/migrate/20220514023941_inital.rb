class Inital < ActiveRecord::Migration[7.0]
  def change
    # TODO: add groups & permissions
    create_table :users do |t|
      t.string :login, null: false, index: true
      t.string :email, null: false, index: true

      t.string :name,  null: false
      t.string :nickname

      t.boolean :admin, null: false, default: false

      t.timestamps null: false, index: true
    end

    create_table :surveys, id: :uuid do |t|
      t.string :name, null: false, index: true
      t.string :slug, null: false, index: true
      t.string :description

      t.bigint :author_id, null: false, index: true
      t.foreign_key :users, column: :author_id, primary_key: :id, on_delete: :cascade

      t.timestamps null: false, index: true
    end

    create_table :survey_drafts do |t|
      t.uuid :survey_id, null: false, index: true
      t.blob :survey_data

      t.boolean :applied, index: true, null: false, default: false
      t.timestamp :applied_at, index: true

      t.timestamp :created_at, index: true
    end

    create_table :question_types do |t|
      t.string :name, null: false, index: true
      t.string :slug, null: false, index: true
      t.string :icon

      t.string :settings

      t.bigint :parent_type_id, index: true
    end

    create_table :questions, id: :uuid do |t|
      t.string  :text,                       null: false
      t.bigint  :hash_code,     index: true, null: false
      t.string  :type,          index: true
      t.integer :display_order, null: false, default: 0
      t.boolean :required,      null: false, default: false

      t.belongs_to :question_type, index: true, null: false
      t.uuid       :survey_id,     index: true, null: false
      t.foreign_key :surveys, column: :survey_id, primary_key: :id, on_delete: :cascade

      t.string :settings

      # Required for FollowupQuestions
      t.uuid       :question_id,     index: true
      t.belongs_to :question_option, index: true
    end

    create_table :question_options do |t|
      t.uuid :question_id, index: true, null: false
      t.foreign_key :questions, column: :question_id, primary_key: :id, on_delete: :cascade

      t.string  :text,   null: false, index: true
      t.integer :weight, index: true # used for numerical weight in generated reports

      t.integer :display_order, null: false, default: 0

      t.uuid :followup_question_id, index: true
      t.foreign_key :questions, column: :followup_question_id, primary_key: :id
    end

    create_table :replies, id: :uuid do |t|
      t.uuid :survey_id, index: true, null: false
      t.string :answer_records

      t.boolean :submitted, null: false, index: true, default: false
      t.timestamp :submitted_at

      t.timestamps
    end

    create_table :answers do |t|
      t.uuid :survey_id,   null: false, index: true
      t.uuid :reply_id,    null: false, index: true
      t.uuid :question_id, null: false, index: true

      t.belongs_to :question_type, index: true # cached data

      # values
      t.belongs_to :question_option,  null: true, index: true
      t.string     :short_text_value, null: true, index: true
      t.text       :long_text_value,  null: true, index: true
      t.integer    :number_value,     null: true, index: true
      t.decimal    :float_value,      null: true, index: true

      t.timestamps
    end
  end
end
