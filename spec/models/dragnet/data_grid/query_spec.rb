require 'rails_helper'

RSpec.describe Dragnet::DataGrid::Query do
  subject(:query) { described_class.new(survey.questions, params) }

  let(:survey) { Dragnet::Survey.generate! }

  describe '#filtered?' do
    it 'returns true when there are filters' do
      query = described_class.new(survey.questions, { filter_by: { user_id: 1 } })

      expect(query).to be_filtered
    end

    it 'returns false when no filters are present' do
      query = described_class.new(survey.questions, {})

      expect(query).not_to be_filtered
    end
  end
end
