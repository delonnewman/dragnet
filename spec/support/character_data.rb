require 'rails_helper'

shared_examples Dragnet::DOM::CharacterData do
  describe '#data' do
    it 'will return the string data' do
      expect(node.data).to be_a String
    end
  end

  describe '#next_element_sibling' do
    subject(:node) do
      described_class.new do |node|
        node.parent = described_class.new(nil, [
          node,
          described_class.empty,
          Dragnet::DOM::Text.empty,
          Dragnet::DOM::Element.new(nil),
          Dragnet::DOM::Element.new(nil)
        ])
      end
    end

    it 'will return the very next sibling of the node that is an element' do
      expect(node.next_element_sibling).to be node.parent.children[3]
    end
  end

  describe '#previous_element_sibling' do
    subject(:node) do
      described_class.new do |node|
        node.parent = described_class.new(nil, [
          Dragnet::DOM::Element.new(nil),
          Dragnet::DOM::Element.new(nil),
          described_class.empty,
          Dragnet::DOM::Text.empty,
          node
        ])
      end
    end

    it 'will return the first sibling before the node that is an element' do
      expect(node.previous_element_sibling).to be node.parent.children[1]
    end
  end
end