# frozen_string_literal: true

describe Dragnet::Question do
  subject(:question) { described_class[survey:].generate! }

  let(:survey) { Dragnet::Survey.generate! }

  it_behaves_like Dragnet::SelfDescribable do
    let(:self_describable) { question }
  end

  it_behaves_like Dragnet::Retractable do
    let(:retractable) { question }
  end

  describe '.whole' do
    before do
      described_class[survey:].generate!
    end

    it "loads all of a questions's componets in one query" do
      relation = described_class.whole

      expect { relation.first.tap { |q| q.question_type; q.question_options.load } }
        .to perform_number_of_queries(2) # performs a prefetch query
    end
  end

  it 'provides a form name' do
    expect(question.form_name).to eq(Dragnet::Utils.slug(question.text, delimiter: '_'))
  end
end
