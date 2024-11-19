# frozen_string_literal: true

describe Dragnet::Reply do
  subject(:reply) { described_class[survey:].generate }

  let(:survey) { Dragnet::Survey.generate }

  it_behaves_like Dragnet::Retractable do
    let(:retractable) { reply }
  end

  it "updates it's survey's latest submission timestamp if submitted" do
    submitted_at = Time.zone.now
    survey.save!
    reply.update(submitted: true, submitted_at:)

    expect(survey.reload.latest_submission_at).to eq submitted_at
  end

  it 'ensures that answers data cache is updated before saving' do
    reply.cached_answers_data = nil

    expect { reply.save! }.to change(reply, :cached_answers_data).from(nil)
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

  describe '#submit' do
    subject(:reply) { described_class[survey:].generate! }

    let(:survey) { Dragnet::Survey[questions: { question_type: Dragnet::QuestionType.get(:text) }].generate! }
    let(:reply_params) { ActionController::Parameters.new(submission_data).permit(*reply.submission_parameters.reply_attributes) }

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
            question_type_id: question.question_type_id,
            value: 'testing',
          },
        },
      }
    end

    it "updates the reply with any attributes that it's been given" do
      reply.save!
      reply.submit(reply_params)

      expect(reply.answers.count).to eq(reply.cached_answers.count)
      expect(reply.answers.map(&:value)).to include(*reply.cached_answers.map(&:value))
      expect(reply.answers.map(&:value)).to include('testing')
    end

    it 'updates answers data cache' do
      reply.cached_answers_data = nil

      expect { reply.submit(submission_data) }.to change(reply, :cached_answers_data).from(nil)
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
