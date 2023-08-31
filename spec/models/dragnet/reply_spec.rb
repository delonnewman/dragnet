# frozen_string_literal: true

require_relative 'retractable'

describe Dragnet::Reply do
  subject(:reply) { described_class[survey: survey].generate }
  let(:survey) { Dragnet::Survey.generate }

  it_behaves_like Dragnet::Retractable do
    let(:retractable) { reply }
  end

  describe '#save' do
    it "will update it's survey's latest submission timestamp if submitted" do
      submitted_at = Time.zone.now
      survey.save!
      reply.update(submitted: true, submitted_at: submitted_at)

      expect(survey.latest_submission_at).to eq submitted_at
    end
  end
end
