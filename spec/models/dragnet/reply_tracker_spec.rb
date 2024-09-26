# frozen_string_literal: true

describe Dragnet::ReplyTracker do
  describe '.event_tags' do
    it 'returns an array of the tags of all the events that can be tracked' do
      expect(described_class.event_tags).to eq(%i[request view update complete])
    end
  end
end
