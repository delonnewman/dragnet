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

  describe '.event_name' do
    it 'returns the name of the event the corresponds to the tag' do
      expect(described_class.event_name(:request)).to eq('Submission Request')
    end

    it 'raises an exception if the tag is not valid' do
      expect { described_class.event_name(:some_invalid_tag) }.to raise_error(/unknown event tag/)
    end
  end
end
