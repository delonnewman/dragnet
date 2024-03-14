# frozen_string_literal: true

describe Dragnet::DataGridPresenter do
  let(:grid) { Dragnet::DataGrid.new(survey:) }
  let(:survey) { Dragnet::Survey.generate! }

  describe '#show_clear_filter?' do
    it 'returns false when there are no filters present' do
      presenter = described_class.new(grid, {})

      expect(presenter).not_to be_show_clear_filter
    end

    it 'returns true when filters are present' do
      presenter = described_class.new(grid, { filter_by: { user_id: 1 } })

      expect(presenter).to be_show_clear_filter
    end
  end

  describe '#records' do
    before do
      10.times { Dragnet::Reply[survey:].generate! }
    end

    it 'returns no more records than the items specified' do
      presenter = described_class.new(grid, { items: 5 })

      expect(presenter.records.count).to be <= 5
    end
  end
end
