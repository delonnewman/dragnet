# frozen_string_literal: true

shared_examples 'self describable' do
  describe '#add_meta' do
    it 'can add single meta data values' do
      self_describable.add_meta(:count, 1)

      expect(self_describable.meta_data).to include({ count: 1 })
    end

    it 'can add multi meta data values' do
      self_describable.add_meta(:counts, [1, 2, 3])

      expect(self_describable.meta_data).to include({ counts: [1, 2, 3] })
    end

    it 'can add reference meta data values' do
      self_describable.add_meta(:ref_count, { a: 1, b: 2, c: 3 })

      expect(self_describable.meta_data).to include({ ref_count: { a: 1, b: 2, c: 3 } })
    end
  end
end
