# frozen_string_literal: true

describe 'Submission Requests', type: :request do
  describe 'GET /r/:survey_id' do
    let(:survey) { Dragnet::Survey[public: false].generate! }

    it 'redirects to root path when a new reply is not permitted' do
      survey.close!
      get reply_to_path(survey.short_id, survey.slug)

      expect(response).to redirect_to(root_path)
    end

    it 'redirects to the edit path of a new reply when permitted' do
      survey.open!
      get reply_to_path(survey.short_id, survey.slug)

      expect(response).to redirect_to(edit_reply_path(survey.replies.last))
    end

    it 'redirects to root path when a reply has already been submitted by the current visitor' do
      survey.open!
      submit_reply
      get reply_to_path(survey.short_id, survey.slug)

      expect(response).to redirect_to(root_path)
    end

    def submit_reply
      get reply_to_path(survey.short_id, survey.slug)
      visit = Ahoy::Visit.find_by!(visit_token: cookies[:ahoy_visit])
      Dragnet::Reply[survey:, submitted: true, ahoy_visit: visit].generate!
    end
  end
end
