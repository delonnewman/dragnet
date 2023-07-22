# frozen_string_literal: true

describe DataGridPresenter do
  subject(:presenter) { described_class.new(grid, params) }

  let(:grid) { DataGrid.new(survey) }
  let(:survey) { Survey.generate! }
  let(:params) { {} }

  describe '#survey_id' do
    it 'returns the surveys id' do
      expect(presenter.survey_id).to eq(survey.id)
    end
  end

  describe '#paginated_records' do
    let(:params) { { items: items } }
    let(:items) { 5 }

    it 'will return no more records than the items specified' do
      expect(presenter.paginated_records.count).to be < items
    end
  end
end
