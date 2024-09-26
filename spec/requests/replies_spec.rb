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

  describe 'PUT/PATCH /replies/:id'
  describe 'POST /replies/:id/submit'
  describe 'GET /replies/:id/complete'
  describe 'GET /reply/:survey_id/preview'
end
