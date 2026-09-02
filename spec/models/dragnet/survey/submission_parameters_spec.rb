# frozen_string_literal: true

describe Dragnet::Survey::SubmissionParameters do
  subject(:parameters) { described_class.new(survey) }

  let(:survey) { Dragnet::Survey.generate! }

  let(:reply) { Dragnet::Reply[survey:].generate! }
  let(:params) { ActionController::Parameters.new(form_data).permit(*survey.submission_parameters.submission_attributes) }

  def form_data
    survey.questions.to_h do |question|
      [question.form_name, Dragnet::AnswerValue[question:].generate]
    end
  end

  it "includes all the parameters for for survey questions in it's form attributes" do
    expect(parameters.submission_attributes).to include(*survey.questions.map(&:form_name))
  end

  it "includes question type ids in the answers attributes of it's form data for all of the surveys questions" do
    data = parameters.submission_data(reply, params)
    type_ids = data[:answers_attributes].map { it[:type] }.uniq
    types = survey.questions.map { it.type.symbol }.uniq

    expect(types).to include(*type_ids)
  end

  it "includes question ids in the answers attributes of it's form data for all of the surveys questions" do
    data = parameters.submission_data(reply, params)
    question_ids = data[:answers_attributes].map { it[:question_id] }

    expect(survey.question_ids).to include(*question_ids)
  end

  it "includes the reply id in the answers attributes of it's form data for all of the surveys questions" do
    data = parameters.submission_data(reply, params)
    reply_ids = data[:answers_attributes].map { it[:reply_id] }

    expect(reply_ids.uniq).to eq([reply.id])
  end

  it "includes the survey id in the answers attributes of it's form data for all of the surveys questions" do
    data = parameters.submission_data(reply, params)
    survey_ids = data[:answers_attributes].map { it[:survey_id] }

    expect(survey_ids.uniq).to eq([survey.id])
  end

  it 'includes the value from the form data in the answers attributes for all of the surveys questions' do
    data = parameters.submission_data(reply, params)
    values = data[:answers_attributes].group_by { it[:question_id] }.map { |_, value| value.first[:value] }

    expect(values.count).to eq(params.values.count)
  end

  it 'provides reply attributes for restricting parameter reply parameters' do
    keys = parameters.reply_attributes[:answers_attributes].keys.sort
    a_value = parameters.reply_attributes[:answers_attributes].values.first

    expect(keys).to eq(survey.question_ids.sort)
    expect(a_value).to include(:survey_id, :question_id, :reply_id, :value)
  end
end
