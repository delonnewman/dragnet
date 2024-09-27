# frozen_string_literal: true

describe 'Replies', type: :request do
  let(:survey) { Dragnet::Survey[public: false].generate! }
  let(:reply) { Dragnet::Reply[survey:, submitted: false].generate! }

  describe 'GET /replies/:id/edit' do
    it 'redirects to root path when editing the reply is not permitted' do
      survey.close!
      get edit_reply_path(reply)

      expect(response).to redirect_to(root_path)
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

      expect(response).to redirect_to(root_path)
    end

    it "renders the edit view if updating the reply is permitted, but the updates aren't valid" do
      survey.open!
      put reply_path(reply), params: { reply: { survey_id: '' } }

      expect(response).to render_template(:edit)
    end

    it 'redirects back to the edit reply path when an update has been successful' do
      survey.open!
      put reply_path(reply), params: update_params

      expect(response).to redirect_to(edit_reply_path(reply))
    end
  end

  describe 'POST /replies/:id/submit' do
    it 'redirects to root path when updating the reply is not permitted' do
      survey.close!
      post submit_reply_path(reply)

      expect(response).to redirect_to(root_path)
    end

    it 'redirects to the complete reply path when the submission has been successful' do
      survey.open!
      post submit_reply_path(reply), params: update_params

      expect(response).to redirect_to(complete_reply_path(reply))
    end

    it "renders the edit view if updating the reply is permitted, but the submission updates aren't valid" do
      survey.open!
      post submit_reply_path(reply), params: { reply: { survey_id: '' } }

      expect(response).to render_template(:edit)
    end
  end

  describe 'GET /replies/:id/complete'
  describe 'GET /reply/:survey_id/preview'

  def update_params
    question = survey.questions.first
    answer = Dragnet::Answer[survey:, reply:, question:].generate

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
            value: answer.value,
          },
        },
      },
    }
  end
end
