# frozen_string_literal: true

describe Dragnet::Reply do
  subject(:reply) { described_class[survey:].generate }

  let(:survey) { Dragnet::Survey.generate }
  let(:submitted_at) { Time.zone.now }

  it_behaves_like Dragnet::Retractable do
    let(:retractable) { reply }
  end

  it "updates it's survey's latest submission timestamp if submitted" do
    survey.save!
    reply.update!(submitted: true, submitted_at:)

    expect(survey.latest_submission_at).to eq submitted_at
  end

  it 'ensures that answers data cache is updated before saving if submitted' do
    survey.save!

    expect { reply.update!(submitted: true, submitted_at:) }.to change(reply, :cached_answers_data).from([])
  end

  it 'provides cached answers' do
    reply.save!

    expect { reply.cached_answers }.to perform_number_of_queries(0)
  end

  it 'when providing answers to a question it used answer cache' do
    question = survey.questions.first
    reply.save!

    expect { reply.answers_to(question) }.to perform_number_of_queries(0)
  end

  context 'when submitting' do
    subject(:reply) { described_class[survey:, submitted: false].generate! }

    let(:survey) { Dragnet::Survey[questions: { type_class: Dragnet::Types::Text }].generate! }

    def submission_data
      question = survey.questions.first

      {
        id: reply.id,
        survey_id: survey.id,
        answers_attributes: {
          question.id => {
            question_id: question.id,
            reply_id: reply.id,
            survey_id: survey.id,
            type_class_name: question.type_class_name,
            value: 'testing',
          },
        },
      }
    end

    it "updates the reply with any attributes that it's been given" do
      original_data = reply.answers.map(&:value)
      reply.submit(submission_data)
      updated_data = reply.reload.answers.map(&:value)

      expect(updated_data).not_to eq(original_data)
    end

    it 'updates answers data cache' do
      expect { reply.submit!(submission_data) }.to change(reply, :cached_answers_data).from([])
    end

    it 'marks it as submitted' do
      reply.submit(submission_data)

      expect(reply).to be_submitted
    end
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
