# frozen_string_literal: true

describe Dragnet::DOM::Node do
  subject(:node) { described_class.new(parent, children) }

  let(:parent) { nil }
  let(:children) { [] }
  let(:empty_node) { described_class.empty }

  describe '#children' do
    let(:children) { [empty_node] }

    it 'will return the children of the node' do
      expect(node.children).to be children
    end

    context 'when nil is given' do
      let(:children) { nil }

      it 'will return an empty array' do
        expect(node.children).to eq []
      end
    end
  end

  describe '#parent' do
    let(:parent) { empty_node }

    it 'will return the parent of the node' do
      expect(node.parent).to be parent
    end

    context 'when nil is given' do
      let(:parent) { nil }

      it 'will return nil' do
        expect(node.parent).to be_nil
      end
    end
  end

  describe '#each' do
    let(:children) { [empty_node, empty_node] }

    it 'will iterate over the children of the node' do
      node.each_with_index do |child, i|
        expect(child).to be children[i]
      end
    end
  end

  describe '#siblings' do
    subject(:node) do
      described_class.new do |node|
        node.parent = described_class.new(nil, [node, empty_node])
      end
    end

    it 'will return the children of the parent node' do
      expect(node.siblings).to be node.parent.children
    end

    it 'will include itself' do
      expect(node.siblings).to include node
    end

    context 'when the parent is nil' do
      subject(:node) { described_class.new(nil) }

      it 'will include an array with just itself' do
        expect(node.siblings).to eq [node]
      end
    end
  end

  describe '#previous_sibling' do
    subject(:node) do
      described_class.new do |node|
        node.parent = described_class.new(nil, [empty_node, empty_node, node])
      end
    end

    it 'will return the sibling before itself' do
      expect(node.previous_sibling).to be node.parent.children[1]
    end

    context 'when there is no sibling before itself' do
      subject(:node) do
        described_class.new do |node|
          node.parent = described_class.new(nil, [node, empty_node])
        end
      end

      it 'will return nil' do
        expect(node.previous_sibling).to be_nil
      end
    end
  end

  describe '#next_sibling' do
    subject(:node) do
      described_class.new do |node|
        node.parent = described_class.new(nil, [node, empty_node, empty_node])
      end
    end

    it 'will return the sibling after itself' do
      expect(node.next_sibling).to be node.parent.children[1]
    end

    context 'when there is no sibling after itself' do
      subject(:node) do
        described_class.new do |node|
          node.parent = described_class.new(nil, [empty_node, node])
        end
      end

      it 'will return nil' do
        expect(node.next_sibling).to be_nil
      end
    end
  end
end