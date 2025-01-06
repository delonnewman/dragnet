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

      expect { relation.first.tap { |a| a.question_option; a.question.tap { |q| q.question_options } } }
        .to perform_number_of_queries(2) # performs a prefetch query
    end
  end
end
