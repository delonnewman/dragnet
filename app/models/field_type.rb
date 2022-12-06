class FieldType < ApplicationRecord
  include Slugged
  include Configurable

  has_many :fields

  setting :countable,        default: false
  setting :long_answer,      default: false
  setting :multiple_answers, default: false
  setting :include_date,     default: false
  setting :include_time,     default: false
end
