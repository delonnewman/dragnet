describe Dragnet::Answer do
  subject(:answer) { described_class.create!(survey:, reply:, question:) }

  let(:survey) { Dragnet::Survey.generate! }
  let(:question) { survey.questions.to_a.sample }
  let(:reply) { Dragnet::Reply[survey:].generate }

  it_behaves_like Dragnet::Retractable do
    let(:retractable) { answer }
  end

  describe '.whole' do
    before do
      described_class[survey:, reply:, question:].generate!
    end

    it "loads all of an answers's componets in one query" do
      relation = described_class.whole

      expect { relation.first.tap { |a| a.question_type; a.question_option; a.question.tap { |q| q.question_type; q.question_options } } }
        .to perform_number_of_queries(2) # performs a prefetch query
    end
  end

  describe '#new' do
    context 'when a question is given, but no question type' do
      it 'the question type will be the same as the question' do
        expect(answer.question_type).to eq(question.question_type)
      end
    end

    context 'when no question is given, and no question type is given' do
      subject(:answer) { described_class.new }

      it 'has a nil question type' do
        expect(answer.question_type).to be_nil
      end
    end
  end
end
