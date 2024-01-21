describe Dragnet::MetaData do
  subject(:meta_data) { described_class.new(self_describable) }

  let(:self_describable) { Dragnet::Survey.generate! }

  describe '.parse' do
    it 'will parse records tha represent single ground values' do

    end
  end

  describe '.attributes' do

  end

  describe '#build' do
    it 'will add single meta data values' do
      meta_data.build(:count, 1)

      expect(meta_data.to_h).to include({ count: 1 })
    end

    it 'can add multi meta data values' do
      meta_data.build(:counts, [1, 2, 3])

      expect(meta_data.to_h).to include({ counts: [1, 2, 3] })
    end

    it 'can add reference meta data values' do
      meta_data.build(:ref_count, { a: 1, b: 2, c: 3 })

      expect(meta_data.to_h).to include({ ref_count: { a: 1, b: 2, c: 3 } })
    end
  end
end
