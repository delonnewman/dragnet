# frozen_string_literal: true

RSpec.describe 'DataGrid::Rows', type: :request do
  let(:reply) do
    survey.replies.create!(
      user:,
      answers_attributes: [{ question_id: question.id, survey_id: survey.id, value: 'this is a test' }]
    )
  end

  let(:user)     { Dragnet::User.generate! }
  let(:survey)   { Dragnet::Survey[author: user, questions: { count: 1, type_class: Dragnet::Types::Text }].generate! }
  let(:question) { survey.questions.first }

  before { sign_in user }

  describe 'GET /surveys/:survey_id/data/rows/:id/edit' do
    it 'renders the edit row form' do
      get edit_survey_data_row_path(survey, reply)

      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /surveys/:survey_id/data/rows/:id' do
    let(:new_value) { 'updated answer text' }
    let(:update_params) do
      answer = reply.answers.find_by(question_id: question.id)
      {
        reply: {
          answers_attributes: {
            question.id => {
              id: answer.id,
              question_id: question.id,
              value:       new_value,
            },
          },
        },
      }
    end

    it 'saves the new answer value' do
      patch survey_data_row_path(survey, reply), params: update_params

      expect(reply.answers.reload.find_by(question:).to_s).to eq(new_value)
    end

    it 'renders the rows partial' do
      patch survey_data_row_path(survey, reply), params: update_params

      expect(response).to have_http_status(:success)
    end

    it 'does not change the submitted_at timestamp' do
      submitted_at = reply.submitted_at

      patch survey_data_row_path(survey, reply), params: update_params

      expect(reply.reload.submitted_at).to eq(submitted_at)
    end
  end
end
