require 'rails_helper'

RSpec.describe Dragnet::Enum do
  subject(:enum) {
    Class.new(described_class) do
      member(:Red, value: 0)
      member(:Green, value: 1)
      member(:Blue, value: 2)
    end
  }

  it 'is a subclass' do
    expect(enum).to be < described_class
  end

  it 'has members' do
    expect(enum.members.count).to be 3
  end

  it 'will return all members' do
    expect(enum.members.map(&:value)).to eq [0, 1, 2]
  end

  it 'has member methods' do
    expect(enum.blue.value).to be 2
  end

  describe 'predicates' do
    it 'has predicates that correspond to itself' do
      expect(enum.blue).to be_blue
    end

    it 'has predicates that correspond to other members' do
      expect(enum.blue).not_to be_red
    end
  end

  describe 'value mapping' do
    it 'matches valid values' do
      expect(enum.of(1).key).to be :green
    end

    it 'raises a type error of the value is invalid' do
      expect { enum.of(3) }.to raise_error(TypeError)
    end
  end

  describe 'key mapping' do
    it 'matches the original symbol name' do
      expect(enum.keyed(:Red).value).to be 0
    end

    it 'matches strings case-insensitively' do
      expect(enum.keyed("grEEn").value).to be 1
    end

    it 'matches symbols case-insensitively' do
      expect(enum.keyed(:bluE).value).to be 2
    end

    it 'raises a type error of the key is invalid' do
      expect { enum.keyed(:yellow) }.to raise_error(TypeError)
    end
  end

  describe 'coercion' do
    it 'coerces valid values' do
      expect(enum.coerce(1).key).to be :green
    end

    it 'coerces valid keys' do
      expect(enum.coerce(:blue).value).to be 2
    end

    it 'raises a type error of the value is not a valid key or value' do
      expect { enum.coerce(:yellow) }.to raise_error(TypeError)
    end
  end

  describe 'equality' do
    it 'is equal to strings that map to valid keys' do
      expect(enum.red).to eq 'Red'
    end

    it 'is equal to symbols that map to valid keys' do
      expect(enum.blue).to eq :BluE
    end

    it 'is equal to values that map to valid values' do
      expect(enum.green).to eq 1
    end
  end
end
