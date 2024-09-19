require 'rails_helper'

RSpec.describe 'DataGrid', type: :request do
  subject(:survey) { Dragnet::Survey[author: user].generate! }

  let(:user) { Dragnet::User.generate! }

  xdescribe 'GET /surveys/:survey_id/data' do
    it 'responds with survey data' do
      sign_in user
      get survey_data_path(survey)

      expect(response).to have_http_status(:success)
    end
  end
end
