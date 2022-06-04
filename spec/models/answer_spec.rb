require 'rails_helper'

RSpec.describe Answer, type: :model do
  describe '#new' do
    context 'when a question is given, but no question type' do
      let(:question) { Question.new(question_type: QuestionType.short_answer) }
      subject(:answer) { described_class.new(question: question) }

      it 'will have the same question type as the question' do
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
