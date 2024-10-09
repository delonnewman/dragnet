# frozen_string_literal: true

describe Dragnet::Survey::SubmissionParameters do
  subject(:parameters) { described_class.new(survey) }

  let(:survey) { Dragnet::Survey.generate! }

  let(:reply) { Dragnet::Reply[survey:].generate! }
  let(:params) { ActionController::Parameters.new(form_data).permit(*survey.form_attributes) }

  def form_data
    survey.questions.each_with_object({}) do |question, h|
      h[question.form_name] = Dragnet::AnswerValue[question:].generate
    end
  end

  it "includes all the parameters for for survey questions in it's form attributes" do
    expect(parameters.form_attributes).to include(*survey.questions.map(&:form_name))
  end

  it "includes question type ids in the answers attributes of it's form data for all of the surveys questions" do
    data = parameters.form_data(reply, params)
    type_ids = data[:answers_attributes].map { _1[:question_type_id] }.uniq
    question_types = survey.questions.map(&:question_type_id).uniq

    expect(question_types).to include(*type_ids)
  end

  it "includes question ids in the answers attributes of it's form data for all of the surveys questions" do
    data = parameters.form_data(reply, params)
    question_ids = data[:answers_attributes].map { _1[:question_id] }

    expect(survey.question_ids).to include(*question_ids)
  end

  it "includes the reply id in the answers attributes of it's form data for all of the surveys questions" do
    data = parameters.form_data(reply, params)
    reply_ids = data[:answers_attributes].map { _1[:reply_id] }

    expect(reply_ids.uniq).to eq([reply.id])
  end

  it "includes the survey id in the answers attributes of it's form data for all of the surveys questions" do
    data = parameters.form_data(reply, params)
    survey_ids = data[:answers_attributes].map { _1[:survey_id] }

    expect(survey_ids.uniq).to eq([survey.id])
  end

  it 'includes the value from the form data in the answers attributes for all of the surveys questions (if values are unique)' do
    data = parameters.form_data(reply, params)
    values = data[:answers_attributes].group_by { _1[:question_id] }.map { |_, value| value.first[:value] }

    expect(values.count).to eq(params.values.count)
  end
end
