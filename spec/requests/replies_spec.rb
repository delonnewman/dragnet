# frozen_string_literal: true

describe 'Replies', type: :request do
  let(:survey) { Dragnet::Survey[public: false, questions: { type_class: }].generate! }
  let(:reply) { Dragnet::Reply[survey:, submitted: false].generate! }
  let(:type_class) { Dragnet::Types::Integer }

  def update_params
    question = survey.questions.first
    value = Dragnet::AnswerValue[question:].generate

    {
      reply: {
        id: reply.id,
        survey_id: survey.id,
        answers_attributes: {
          question.id => {
            question_id: question.id,
            reply_id: reply.id,
            survey_id: survey.id,
            question_type_id: question.question_type_id,
            value:,
          },
        },
      },
    }
  end

  def invalid_update_params
    question = survey.questions.first
    question_type_id = question.question_type_id
    question_id = question.id

    # missing survey_id
    { reply: { answers_attributes: { question_id => { question_id:, question_type_id:, value: 1 } } } }
  end

  describe 'GET /replies/:id/edit' do
    it 'redirects to root path when editing the reply is not permitted' do
      survey.close! rescue binding.pry
      get edit_reply_path(reply)

      expect(response).to redirect_to(survey_forbidden_path)
    end

    it 'renders edit view if the reply is permitted' do
      survey.open!
      get edit_reply_path(reply)

      expect(response).to render_template(:edit)
    end
  end

  describe 'PUT /replies/:id' do
    it 'redirects to root path when updating the reply is not permitted' do
      survey.close!
      put reply_path(reply)

      expect(response).to redirect_to(survey_forbidden_path)
    end

    it "renders the edit view if updating the reply is permitted, but the updates aren't valid" do
      survey.open!
      put reply_path(reply), params: invalid_update_params

      expect(response).to render_template(:edit)
    end

    it 'redirects back to the edit reply path when an update has been successful' do
      survey.open!
      put reply_path(reply), params: update_params

      expect(response).to redirect_to(edit_reply_path(reply))
    end
  end

  describe 'POST /replies/:id/submit' do
    it 'redirects to root path when completing the reply is not permitted' do
      survey.close!
      post submit_reply_path(reply)

      expect(response).to redirect_to(survey_forbidden_path)
    end

    it 'redirects to the complete reply path when the submission has been successful' do
      survey.open!
      post submit_reply_path(reply), params: update_params

      expect(response).to redirect_to(complete_reply_path(reply))
    end

    it "renders the edit view if updating the reply is permitted, but the submission updates aren't valid" do
      survey.open!
      post submit_reply_path(reply), params: invalid_update_params

      expect(response).to render_template(:edit)
    end
  end

  describe 'GET /replies/:id/complete' do
    it 'redirects to root path when completing the reply is not permitted' do
      survey.close!
      get complete_reply_path(reply)

      expect(response).to redirect_to(survey_forbidden_path)
    end

    it 'renders the success view if completing the reply is permitted' do
      survey.open!
      get complete_reply_path(reply)

      expect(response).to render_template(:success)
    end
  end

  describe 'GET /reply/:survey_id/preview' do
    it 'redirects to root path when previewing is not permitted' do
      survey.close!
      get preview_form_path(survey.id)

      expect(response).to redirect_to(survey_forbidden_path)
    end

    it 'renders the edit view when previewing is permitted' do
      survey.open!
      get preview_form_path(survey.id)

      expect(response).to render_template(:edit)
    end
  end
end
