# frozen_string_literal: true

describe Dragnet::Survey::SubmissionParametersProjection do
  subject(:projection) { described_class.new(survey) }

  let(:survey) { Dragnet::Survey.generate! }

  it 'includes id and survey_id' do
    expect(projection.project).to include(:id, :survey_id)
  end

  it 'includes the correct attributes that are required for answer submission' do
    attributes = %i[question_id reply_id survey_id question_type_id value]

    expect(projection.project.last[:answers_attributes].values.first).to eq(attributes)
  end
end
