# frozen_string_literal: true

shared_examples Dragnet::SelfDescribable do
  describe '#meta_data=' do
    it 'assigns meta data to the record' do
      self_describable.meta = { count: 1 }

      expect(self_describable.meta.to_h).to include({ count: 1 })
    end
  end
end
