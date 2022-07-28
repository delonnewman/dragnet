require 'rails_helper'

describe Answer, type: :model do
  describe '#new' do
    context 'when a question is given, but no question type' do
      let(:survey) { Survey.generate.tap(&:save!) }
      let(:question) { survey.questions.to_a.sample }
      let(:reply) { Reply[survey: survey].generate }
      subject(:answer) { described_class.create!(survey: survey, reply: reply, question: question) }

      it 'the question type will be the same as the question' do
        expect(answer.question_type).to eq(question.question_type)
      end
    end

    context 'when no question is given, and no question type is given' do
      subject(:answer) { described_class.new }

      it 'will have a nil question type' do
        expect(answer.question_type).to be_nil
      end
    end
  end
end
