# frozen_string_literal: true

class Survey < ApplicationRecord
  include Slugged
  include UniquelyIdentified

  belongs_to :author, class_name: 'User'

  has_many :questions, -> { order(:display_order) }, dependent: :delete_all
  accepts_nested_attributes_for :questions

  has_many :replies
  has_many :answers

  def self.init(attributes = EMPTY_HASH)
    n    = where("name = 'New Survey' or name like 'New Survey (%)'").count
    name = n.zero? ? 'New Survey' : "New Survey (#{n})"

    new(attributes.reverse_merge(name: name))
  end

  def projection
    data = pull(
      :name,
      :description,
      questions: [
        :id,
        :text,
        :display_order,
        :required,
        :question_type_id,
        {
          question_options: %i[id text weight]
        }
      ]
    )

    questions = data[:questions].inject({}) do |qs, q|
      q[:question_options] = q[:question_options].inject({}) { |opts, opt| opts.merge!(opt[:id] => opt) }
      qs.merge!(q[:id] => q)
    end

    data.merge(questions: questions)
  end

  def draft
    SurveyDraft.new(survey: self, survey_data: projection)
  end
end
