# frozen_string_literal: true

describe Dragnet::DOM::Text do
  subject(:node) do
    described_class.new do |node|
      node.data = "this is a test"
    end
  end

  it_behaves_like Dragnet::DOM::CharacterData
end