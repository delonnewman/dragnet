# frozen_string_literal: true

describe 'Submission Requests', type: :request do
  let(:survey) { Dragnet::Survey[public: false].generate! }

  def create_reply(submitted: false)
    get reply_to_path(survey.short_id, survey.slug)
    visit = Ahoy::Visit.find_by!(visit_token: cookies[:ahoy_visit])
    Dragnet::Reply[survey:, submitted:, ahoy_visit: visit].generate!
  end

  def submission_data
    survey.questions.each_with_object({}) do |question, form_data|
      form_data[question.form_name] = Dragnet::AnswerValue[question:].generate
    end
  end

  describe 'GET /r/:survey_id' do
    it 'redirects to survey forbidden path when a new reply is not permitted' do
      survey.close!
      get reply_to_path(survey.short_id, survey.slug)

      expect(response).to redirect_to(survey_forbidden_path)
    end

    it 'redirects to the edit path of a new reply when permitted' do
      survey.open!
      get reply_to_path(survey.short_id, survey.slug)

      expect(response).to redirect_to(edit_reply_path(survey.replies.last))
    end

    it 'redirects to survey forbidden path when a reply has already been submitted by the current visitor' do
      survey.open!
      create_reply submitted: true
      get reply_to_path(survey.short_id, survey.slug)

      expect(response).to redirect_to(survey_forbidden_path)
    end

    it 'redirects to the edit path of an existing reply when permitted and an reply already exists for the visitor' do
      survey.open!
      create_reply
      get reply_to_path(survey.short_id, survey.slug)
      reply = survey.existing_reply(cookies[:ahoy_visitor])

      expect(response).to redirect_to(edit_reply_path(reply))
    end
  end

  describe 'POST /r/:survey_id' do
    it 'redirects to survey forbidden path when a new reply is not permitted' do
      survey.close!
      post reply_to_path(survey.short_id, survey.slug)

      expect(response).to redirect_to(survey_forbidden_path)
    end

    it 'redirects to survey forbidden path when a reply has already been submitted by the current visitor' do
      survey.open!
      create_reply submitted: true
      post reply_to_path(survey.short_id, survey.slug)

      expect(response).to redirect_to(survey_forbidden_path)
    end

    it 'renders replies/success template when the submission has been successful' do
      survey.open!
      post reply_to_path(survey.short_id, survey.slug), params: submission_data

      expect(response).to render_template('replies/success')
    end
  end

  describe 'GET /reply/404' do
    it 'returns http not found' do
      get '/reply/404'
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /reply/403' do
    it 'returns http forbidden' do
      get '/reply/403'
      expect(response).to have_http_status(:forbidden)
    end
  end
end
