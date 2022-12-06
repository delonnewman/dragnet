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

    create_table :forms, id: :uuid do |t|
      t.string :name, null: false, index: true
      t.string :slug, null: false, index: true
      t.string :description

      t.bigint :author_id, null: false, index: true
      t.foreign_key :users, column: :author_id, primary_key: :id, on_delete: :cascade

      t.timestamps null: false, index: true
    end

    create_table :form_edits do |t|
      t.uuid :form_id, null: false, index: true
      t.blob :form_data

      t.boolean :applied, index: true, null: false, default: false
      t.timestamp :applied_at, index: true

      t.timestamp :created_at, index: true
    end

    create_table :field_types do |t|
      t.string :name, null: false, index: true
      t.string :slug, null: false, index: true
      t.string :icon

      t.string :settings

      t.bigint :parent_type_id, index: true
    end

    create_table :fields, id: :uuid do |t|
      t.string  :text,                       null: false
      t.bigint  :hash_code,     index: true, null: false
      t.string  :type,          index: true
      t.integer :display_order, null: false, default: 0
      t.boolean :required,      null: false, default: false

      t.belongs_to :field_type, index: true, null: false
      t.uuid       :form_id,    index: true, null: false
      t.foreign_key :forms, column: :form_id, primary_key: :id, on_delete: :cascade

      t.string :settings

      # Required for DependentFields
      t.uuid       :dependent_field_id, index: true
      t.belongs_to :field_option, index: true
    end

    create_table :field_options do |t|
      t.uuid :field_id, index: true, null: false
      t.foreign_key :fields, column: :field_id, primary_key: :id, on_delete: :cascade

      t.string  :text,   null: false, index: true
      t.integer :weight, index: true # used for numerical weight in generated reports

      t.integer :display_order, null: false, default: 0

      t.uuid :dependent_field_id, index: true
      t.foreign_key :fields, column: :dependent_field_id, primary_key: :id
    end

    create_table :responses, id: :uuid do |t|
      t.uuid :form_id, index: true, null: false
      t.string :response_item_cache

      t.boolean :submitted, null: false, index: true, default: false
      t.timestamp :submitted_at

      t.timestamps
    end

    create_table :response_items do |t|
      t.uuid :form_id,     null: false, index: true
      t.uuid :response_id, null: false, index: true
      t.uuid :field_id,    null: false, index: true

      t.belongs_to :field_type, index: true # cached data

      # values
      t.belongs_to :field_option,     null: true, index: true
      t.string     :short_text_value, null: true, index: true
      t.text       :long_text_value,  null: true, index: true
      t.integer    :number_value,     null: true, index: true
      t.decimal    :float_value,      null: true, index: true

      t.timestamps
    end
  end
end
