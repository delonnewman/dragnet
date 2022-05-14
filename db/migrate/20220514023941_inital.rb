class Inital < ActiveRecord::Migration[7.0]
  def change
    # TODO: add groups
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

      t.belongs_to :user, null: false, index: true

      t.timestamps null: false, index: true
    end

    create_table :question_types do |t|
      t.string :name, null: false, index: true
      t.string :slug, null: false, index: true
    end

    create_table :questions, id: :uuid do |t|
      t.string     :text,                       null: false
      t.bigint     :hash_code,     index: true, null: false
      t.string     :type,          index: true

      t.belongs_to :question_type, index: true, null: false
      t.belongs_to :survey,        index: true, null: false
      t.belongs_to :question,      index: true
    end

    create_table :question_options do |t|
      t.belongs_to :question, index: true, null: false

      t.string  :text,  null: false, index: true
      t.integer :scale, null: false, index: true

      t.uuid :followup_question_id, index: true
      t.foreign_key :questions, column: :followup_question_id, primary_key: :id
    end

    create_table :replies, id: :uuid do |t|
      t.belongs_to :survey, index: true, null: false

      t.timestamps
    end

    create_table :answers do |t|
      t.belongs_to :survey,   null: false, index: true
      t.belongs_to :reply,    null: false, index: true
      t.belongs_to :question, null: false, index: true

      # values
      t.belongs_to :question_option
      t.string     :short_text_value
      t.text       :long_text_value
      t.integer    :number_value
      t.decimal    :float_value
    end
  end
end
