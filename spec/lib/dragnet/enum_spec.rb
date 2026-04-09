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

  it 'maps members to values' do
    expect(enum.of(0).value).to be 0
  end

  it 'maps members to keys' do
    expect(enum.keyed(:Red).value).to be 0
  end

  it 'will return all members' do
    expect(enum.members.map(&:value)).to eq [0, 1, 2]
  end
end
