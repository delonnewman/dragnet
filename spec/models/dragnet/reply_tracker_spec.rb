# frozen_string_literal: true

describe Dragnet::ReplyTracker do
  subject(:tracker) { described_class.new(ahoy) }

  let(:ahoy) { Ahoy::Tracker.new }

  let(:reply) { Dragnet::Reply[survey:].generate! }
  let(:survey) { Dragnet::Survey.generate! }

  before do
    ahoy.track_visit
  end

  it 'tracks visitor events for replies' do
    expect { tracker.track_event(:view, reply) }.to change { reply.events.count }.by(1)
  end

  it 'ensures that replies have the correct visit associated with them when tracking events' do
    expect { tracker.track_event(:request, reply) }.to change(reply, :ahoy_visit).from(nil).to(ahoy.visit)
  end

  it 'provides a helper method for request events' do
    expect { tracker.request_submission_form(reply) }.to change { reply.events.by_reply_event_tag(:request).count }.from(0).to(1)
  end

  it 'provides a helper method for view events' do
    expect { tracker.view_submission_form(reply) }.to change { reply.events.by_reply_event_tag(:view).count }.from(0).to(1)
  end

  it 'provides a helper method for update events' do
    expect { tracker.update_submission_form(reply) }.to change { reply.events.by_reply_event_tag(:update).count }.from(0).to(1)
  end

  it 'provides a helper method for complete events' do
    expect { tracker.complete_submission_form(reply) }.to change { reply.events.by_reply_event_tag(:complete).count }.from(0).to(1)
  end

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
