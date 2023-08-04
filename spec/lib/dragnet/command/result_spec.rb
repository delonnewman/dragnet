# frozen_string_literal: true

describe Dragnet::Command::Result do
  it 'can stash arbitrary values' do
    result = described_class.new
    value  = 'testing'

    result.this_is_a_test = value

    expect(result.this_is_a_test).to be value
  end

  it 'can test for the presence of stashed values' do
    result = described_class.new
    result.this_is_a_test = 'hey'

    expect(result).to be_this_is_a_test
  end

  describe '.new' do
    it 'takes no arguments' do
      expect { described_class.new }.not_to raise_exception
    end

    it 'initializes failure? to false' do
      expect(described_class.new).not_to be_failure
    end
  end

  describe '#failure!' do
    it 'asserts the result is a failure' do
      result = described_class.new
      result.failure!('this is a test error')

      expect(result).to be_failure
    end

    it 'sets the error message of the result' do
      result = described_class.new
      message = 'this is a test error'

      expect { result.failure!(message) }.to change { result.error }.from(nil).to(message)
    end
  end

  describe '#successful?' do
    it 'returns true if the result is not a failure' do
      expect(described_class.new).to be_successful
    end

    it 'returns false if the result is a failure' do
      result = described_class.new
      result.failure!('this is a test')

      expect(result).not_to be_successful
    end
  end
end
