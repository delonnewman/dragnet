require 'rails_helper'

RSpec.describe Dragnet::DataGrid::QueryRelation do
  subject(:relation) { described_class.new(Dragnet::DataGrid::Query.new(survey.questions, params), survey.replies) }

  let(:params) { {} }
  let!(:survey) { Dragnet::Survey.generate! }

  before do
    10.times { Dragnet::Reply[survey:].generate! }
  end

  it 'avoids N+1s' do
    expect { relation.build.load }.to perform_number_of_queries 5
  end
end
