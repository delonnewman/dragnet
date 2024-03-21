describe Dragnet::MetaData do
  subject(:meta_data) { described_class.new(self_describable) }

  let!(:self_describable) { Dragnet::Survey.generate! }

  describe '#add!' do
    it 'adds single meta data values' do
      meta_data[:count] = 1

      expect(meta_data.to_h).to include({ count: 1 })
    end

    it 'can add multi meta data values' do
      meta_data[:counts] = [1, 2, 3]

      expect(meta_data.to_h).to include({ counts: [1, 2, 3] })
    end

    it 'can add reference meta data values' do
      meta_data[:ref_count] = { a: 1, b: 2, c: 3 }

      expect(meta_data.to_h).to include({ ref_count: { a: 1, b: 2, c: 3 } })
    end
  end

  describe '.new' do
    it 'does not perform any queries' do
      expect { described_class.new(self_describable) }.to perform_number_of_queries 0
    end
  end
end
