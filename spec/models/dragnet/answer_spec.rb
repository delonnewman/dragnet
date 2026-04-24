RSpec.describe Dragnet::Answer do
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

  describe Dragnet::Answer::DoBeforeSaving do
    subject(:survey) do
      Survey.create!(
        name: Dragnet::Generators::Name.generate,
        author: Dragnet::User.generate,
        questions_attributes: [
          { text: 'Comments', type_class: Dragnet::Types::LongText, meta: { countable: true } },
        ]
      );
    end

    let(:reply) { survey.replies.create! }
    let(:value) { Dragnet::Generators::LongAnswer.generate }
    let(:question) { survey.questions.find_by({ text: 'Comments' }) }
    let(:answer) { reply.answers.create!(survey:, question:, value:) }

    it 'sets LongText value' do
      expect(answer.long_text_value).to eq(value)
    end

    it 'sets Float value' do
      expect(answer.float_value).not_to be(nil)
    end
  end
end
