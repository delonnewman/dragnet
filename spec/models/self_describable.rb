# frozen_string_literal: true

shared_examples 'self describable' do
  describe '#build_meta_datum' do
    it 'will add single meta data values' do
      self_describable.build_meta_datum(:count, 1)

      expect(self_describable.meta_data).to include({ count: 1 })
    end

    it 'can add multi meta data values' do
      self_describable.build_meta_datum(:counts, [1, 2, 3])

      expect(self_describable.meta_data).to include({ counts: [1, 2, 3] })
    end

    it 'can add reference meta data values' do
      self_describable.build_meta_datum(:ref_count, { a: 1, b: 2, c: 3 })

      expect(self_describable.meta_data).to include({ ref_count: { a: 1, b: 2, c: 3 } })
    end
  end

  describe '#meta_data=' do
    it 'will assign meta data to the record' do
      self_describable.meta_data = { count: 1 }

      expect(self_describable.meta_data).to include({ count: 1 })
    end
  end
end
