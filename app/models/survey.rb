# frozen_string_literal: true

class Survey < ApplicationRecord
  include Slugged
  include UniquelyIdentified

  belongs_to :author, class_name: 'User'

  has_many :questions, -> { order(:display_order) }, dependent: :delete_all
  accepts_nested_attributes_for :questions

  has_many :replies
  has_many :answers

  has_many :drafts, -> { where(applied: false) }, class_name: 'SurveyDraft', dependent: :delete_all

  def self.init(attributes = EMPTY_HASH)
    n    = where("name = 'New Survey' or name like 'New Survey (%)'").count
    name = n.zero? ? 'New Survey' : "New Survey (#{n})"

    new(attributes.reverse_merge(name: name))
  end

  def new_draft
    SurveyDraft.new(survey: self, survey_data: projection)
  end

  def latest_draft
    drafts.where(applied: false).order(created_at: :desc).first
  end

  def draft?
    latest_draft.present?
  end

  def current_draft
    latest_draft || new_draft
  end

  def projection
    data = pull(
      :id,
      :name,
      :description,
      :updated_at,
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

    data[:updated_at] = data[:updated_at].to_time

    questions = data[:questions].inject({}) do |qs, q|
      q[:question_options] = q[:question_options].inject({}) { |opts, opt| opts.merge!(opt[:id] => opt) }
      qs.merge!(q[:id] => q)
    end

    data.merge(questions: questions)
  end
end
