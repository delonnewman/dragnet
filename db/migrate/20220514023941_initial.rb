class Initial < ActiveRecord::Migration[7.0]
  def change
    # TODO: add groups & permissions
    create_table :users, id: :uuid do |t|
      t.string :login, null: false, index: true
      t.string :email, null: false, index: true

      t.string :name,  null: false
      t.string :nickname

      t.boolean :admin, null: false, default: false

      t.json :meta_data
      t.timestamps null: false, index: true
    end

    create_table :surveys, id: :uuid do |t|
      t.string :name, null: false, index: true
      t.string :slug, null: false, index: true
      t.string :description

      t.uuid :author_id, null: false, index: true
      t.foreign_key :users, column: :author_id, primary_key: :id, on_delete: :cascade
      t.index [:name, :author_id], unique: true

      t.uuid    :copy_of_id,            null: true, index: true
      t.integer :edits_status,          null: true, index: true
      t.integer :record_changes_status, null: true, index: true

      t.boolean :open,   index: true, null: false, default: false
      t.boolean :public, index: true, null: false, default: false

      t.boolean   :retracted,    null: false, index: true, default: false
      t.timestamp :retracted_at,              index: true
      t.timestamp :latest_submission_at,      index: true

      t.json :meta_data
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
      t.uuid    :survey_id,          null: false, index: true
      t.string  :trigger_class_name, null: false, index: true, default: 'Dragnet::Triggers::UserDefinedTrigger'
      t.boolean :user_defined,       null: false, index: true, default: true
      t.blob    :logic

      t.timestamps index: true
    end

    create_table :trigger_executions do |t|
      t.belongs_to :trigger_registration, type: :uuid, null: false, index: true
      t.integer    :status,                            null: true, index: true
      t.blob       :output
      t.boolean    :completed,                         null: false, index: true, default: false
      t.timestamp  :completed_at,                                   index: true

      t.timestamps index: true
    end

    create_table :question_types, id: :uuid do |t|
      t.string :name, null: false, index: true
      t.string :slug, null: false, index: true
      t.string :icon
      t.string :type_class_name, null: false

      t.uuid :parent_type_id, index: true
      t.json :meta_data
    end

    create_table :type_registrations, id: :uuid do |t|
      t.string :name, null: false, index: true
      t.string :slug, null: false, index: true
      t.string :type_class_name, null: false
      t.boolean :abstract, null: false, default: false, index: true

      t.uuid :parent_type_id, index: true
      t.json :meta_data
    end

    create_table :questions, id: :uuid do |t|
      t.string  :text,                       null: false
      t.bigint  :hash_code,     index: true, null: false
      t.integer :display_order, null: false, default: 0
      t.string  :form_name,     index: true, null: false
      t.boolean :required,      null: false, default: false

      t.belongs_to :question_type, index: true, null: false, type: :uuid
      t.string :type_class_name, index: true, null: false

      t.uuid       :survey_id,     index: true, null: false
      t.foreign_key :surveys, column: :survey_id, primary_key: :id, on_delete: :cascade

      t.boolean :retracted, default: false, null: false, index: true
      t.timestamp :retracted_at, index: true

      t.json :meta_data
    end

    create_table :question_options do |t|
      t.uuid :question_id, index: true, null: false
      t.foreign_key :questions, column: :question_id, primary_key: :id, on_delete: :cascade

      t.string  :text,   null: false, index: true
      t.integer :weight,              index: true # used for numerical weight in generated reports

      t.integer :display_order, null: false, default: 0
    end

    create_table :replies, id: :uuid do |t|
      t.uuid :survey_id, index: true, null: false
      t.uuid :user_id,   index: true, null: true # for records added via data grid
      t.json :cached_answers_data, null: false

      # security
      t.string :csrf_token, null: false
      t.timestamp :expires_at, null: false, index: true

      # submission
      t.boolean :submitted, null: false, index: true, default: false
      t.timestamp :submitted_at

      # retraction
      t.boolean :retracted, default: false, null: false, index: true
      t.timestamp :retracted_at, index: true

      t.json :meta_data
      t.timestamps
    end

    create_table :answers, id: :uuid do |t|
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

      t.boolean :retracted, default: false, null: false, index: true
      t.timestamp :retracted_at, index: true

      t.json :meta_data
      t.timestamps
    end

    create_table :record_changes do |t|
      t.belongs_to :survey,            type: :uuid, null: false, index: true
      t.boolean    :retraction,                     null: false, index: true, default: false
      t.string     :record_class_name,              null: false, index: true
      t.uuid       :record_id,                      null: false, index: true
      t.blob       :changes
      t.blob       :diff
      t.boolean    :applied,                        null: false, index: true, default: false
      t.timestamp  :applied_at,                                  index: true
      t.timestamp  :created_at,                     null: false, index: true
      t.uuid       :created_by,                                  index: true
    end

    create_table :data_grids do |t|
      t.belongs_to :survey, type: :uuid, null: false, index: true
      t.belongs_to :user,   type: :uuid, null: false, index: true
      t.index [:survey_id, :user_id], unique: true
    end

    create_table :saved_reports, id: :uuid do |t|
      t.uuid        :author_id, null: false, index: true
      t.foreign_key :users,     column: :author_id, primary_key: :id, on_delete: :cascade

      t.string :name,         null: false
      t.string :question_ids, null: false
      t.string :filters
      t.string :sort_by
      t.string :sort_direction
      t.json :meta_data
    end
  end
end
