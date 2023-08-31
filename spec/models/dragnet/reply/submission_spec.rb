# frozen_string_literal: true

describe Dragnet::Reply::Submission do
  subject(:reply_submission) { described_class.new(reply) }

  let(:reply) { Dragnet::Reply[survey: survey].generate }
  let(:survey) { Dragnet::Survey.generate }

  describe '#submitted!' do
    let(:timestamp) { Time.zone.now }

    before do
      reply_submission.submitted!(timestamp)
    end

    it 'flags the reply as submitted' do
      expect(reply).to be_submitted
    end

    it 'sets the submission timestamp' do
      expect(reply.submitted_at).to be timestamp
    end
  end

  describe '#submit' do
    let(:attributes) { {} }

    before do
      reply_submission.submit!(attributes)
    end

    it 'updates the reply with the given attributes'
    it 'validates the reply'

    it 'saves the reply in a submitted state' do
      expect(reply).to be_submitted
    end
  end
end
