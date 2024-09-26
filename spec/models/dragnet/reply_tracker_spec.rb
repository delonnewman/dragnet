# frozen_string_literal: true

describe Dragnet::ReplyTracker do
  describe '.event_tags' do
    it 'returns an array of the tags of all the events that can be tracked' do
      expect(described_class.event_tags).to eq(%i[request view update complete])
    end
  end

  describe '.event_names' do
    it 'returns an array of the names of all the events that can be tracked' do
      event_names = ['Submission Request', 'View Submission Form', 'Update Submission Form', 'Complete Submission Form']

      expect(described_class.event_names).to eq(event_names)
    end
  end
end
