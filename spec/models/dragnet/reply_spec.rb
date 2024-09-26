# frozen_string_literal: true

describe Dragnet::Reply do
  subject(:reply) { described_class[survey: survey].generate }

  let(:survey) { Dragnet::Survey.generate }

  it_behaves_like Dragnet::Retractable do
    let(:retractable) { reply }
  end

  it "updates it's survey's latest submission timestamp if submitted" do
    submitted_at = Time.zone.now
    survey.save!
    reply.update(submitted: true, submitted_at:)

    expect(survey.latest_submission_at).to eq submitted_at
  end

  describe '#ensure_visit' do
    let(:visit) { Ahoy::Visit.generate! }

    it 'updates the reply with the visit if a visit is not present' do
      reply.ahoy_visit = nil

      expect { reply.ensure_visit(visit) }.to change(reply, :ahoy_visit).to(visit)
    end

    it 'updates the reply with the visit if the visit assocated with the reply is not the same' do
      reply.ahoy_visit = Ahoy::Visit.generate!

      expect { reply.ensure_visit(visit) }.to change(reply, :ahoy_visit).to(visit)
    end

    it 'does not update the reply if the visit associated with the reply is the same' do
      reply.ahoy_visit = visit

      expect { reply.ensure_visit(visit) }.not_to change(reply, :ahoy_visit)
    end

    it 'does not perform any database queries if an update is not required' do
      reply.ahoy_visit = visit

      expect { reply.ensure_visit(visit) }.to perform_number_of_queries(0)
    end

    it "doesn't update the visit if it's nil even if the visit associated with the reply is not the same" do
      reply.ahoy_visit = Ahoy::Visit.generate!

      expect { reply.ensure_visit(nil) }.not_to change(reply, :ahoy_visit)
    end
  end
end
