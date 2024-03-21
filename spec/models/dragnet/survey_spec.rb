# frozen_string_literal: true

describe Dragnet::Survey do
  subject(:survey) { described_class.whole.create!(name:, author:) }

  let(:name) { Dragnet::Generators::Name.generate }
  let(:author) { Dragnet::User.generate! }

  it_behaves_like Dragnet::SelfDescribable do
    let(:self_describable) { survey }
  end

  it_behaves_like Dragnet::Retractable do
    let(:retractable) { survey }
  end

  describe '.whole' do
    before do
      described_class.generate!
    end

    it "loads all of a survey's componets in one query" do
      relation = described_class.whole

      expect { relation.first.questions.each { |q| q.question_type; q.question_options.load } }
        .to perform_number_of_queries(2) # performs a prefetch query
    end
  end

  describe '#save' do
    it 'generates a slug when no slug is given' do
      expect(survey.slug).to eq Dragnet::Utils.slug(survey.name)
    end

    it 'uses the given slug when a slug is given' do
      survey = described_class.create!(name:, slug: 'testing-123', author:)

      expect(survey.slug).to eq 'testing-123'
    end

    it 'uses the given name when a name is given' do
      expect(survey.name).to eq name
    end

    context 'when no name is given' do
      let(:name) { nil }

      it 'generates a name' do
        expect(survey.name).not_to be_blank
      end
    end

    context 'when no edit status is given' do
      it 'sets the edit status to :saved' do
        expect(survey).to be_edits_saved
      end
    end

    context 'when an edit status is given' do
      subject(:survey) { described_class.create!(name:, edits_status:, author:) }

      let(:edits_status) { 'unsaved' }

      it 'sets the edit status to :saved' do
        expect(survey.edits_status).to eq(edits_status)
      end
    end
  end
end
