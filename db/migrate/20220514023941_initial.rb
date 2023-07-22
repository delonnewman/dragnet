class Initial < ActiveRecord::Migration[7.0]
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

      t.string :type, null: true, index: true

      t.bigint :author_id, null: false, index: true
      t.foreign_key :users, column: :author_id, primary_key: :id, on_delete: :cascade
      t.index [:name, :author_id], unique: true

      t.uuid :copy_of_id, null: true, index: true
      t.integer :edits_status, null: true, index: true

      t.boolean :open, index: true, null: false, default: false
      t.boolean :public, index: true, null: false, default: false

      t.timestamp :latest_submission_at, index: true
      t.timestamps null: false, index: true
    end

    create_table :survey_edits do |t|
      t.uuid :survey_id, null: false, index: true
      t.blob :survey_data

      t.boolean :applied, index: true, null: false, default: false
      t.timestamp :applied_at, index: true

      t.timestamp :created_at, index: true
    end

    create_table :trigger_registrations do |t|
      t.uuid :survey_id, null: false, index: true
      t.string :trigger_class_name, null: false, index: true

      t.timestamps
    end

    create_table :question_types, id: :uuid do |t|
      t.string :name, null: false, index: true
      t.string :slug, null: false, index: true
      t.string :icon

      t.string :settings

      t.uuid :parent_type_id, index: true
    end

    create_table :questions, id: :uuid do |t|
      t.string  :text,                       null: false
      t.bigint  :hash_code,     index: true, null: false
      t.string  :type,          index: true
      t.integer :display_order, null: false, default: 0
      t.boolean :required,      null: false, default: false

      t.belongs_to :question_type, index: true, null: false, type: :uuid
      t.uuid       :survey_id,     index: true, null: false
      t.foreign_key :surveys, column: :survey_id, primary_key: :id, on_delete: :cascade

      t.string :config # TODO: remove

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
      t.string :answer_records # cached records

      t.boolean :submitted, null: false, index: true, default: false
      t.timestamp :submitted_at

      t.timestamps
    end

    create_table :answers do |t|
      t.uuid :survey_id,   null: false, index: true
      t.uuid :reply_id,    null: false, index: true
      t.uuid :question_id, null: false, index: true

      t.belongs_to :question_type, index: true, type: :uuid # cached data

      # values
      t.belongs_to :question_option,  null: true, index: true
      t.string     :short_text_value, null: true, index: true
      t.text       :long_text_value,  null: true, index: true
      t.integer    :integer_value,    null: true, index: true
      t.boolean    :boolean_value,    null: true, index: true
      t.decimal    :float_value,      null: true, index: true
      t.time       :time_value,       null: true, index: true
      t.date       :date_value,       null: true, index: true

      t.timestamps
    end

    create_table :meta_data do |t|
      t.references :self_describable, polymorphic: true, type: :uuid
      t.string :key, null: false, index: true
      t.string :key_type, null: false, index: true, default: 'String'
      t.string :value, null: false, index: true
    end

    create_table :saved_reports, id: :uuid do |t|
      t.bigint :author_id, null: false, index: true
      t.foreign_key :users, column: :author_id, primary_key: :id, on_delete: :cascade

      t.string :name, null: false
      t.string :question_ids, null: false
      t.string :filters
      t.string :sort_by
      t.string :sort_direction
    end
  end
end
