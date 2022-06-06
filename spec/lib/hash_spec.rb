RSpec.describe Hash do
  describe '#assert_keys' do
    subject(:hash) { { a: 1, b: 2, c: 3 } }

    it 'will raise an exception if any keys are missing' do
      expect { hash.assert_keys(:a, :e) }.to raise_error(/missing key/)
    end

    it 'will return a hash with the specified keys' do
      expect(hash.assert_keys(:a, :b)).to eq({ a: 1, b: 2 })
    end
  end
end
