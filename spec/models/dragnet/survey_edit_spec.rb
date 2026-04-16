# frozen_string_literal: true

describe Dragnet::SurveyEdit do
  let(:author) { Dragnet::User.generate! }
  let(:survey) { Dragnet::Survey.create!(author:) }

  context 'when the survey has no un-applied edits' do
    describe '.latest' do
      it 'returns nil' do
        expect(described_class.latest(survey)).to be_nil
      end
    end

    describe '.present?' do
      it 'is false' do
        expect(described_class).not_to be_present(survey)
      end
    end
  end

  context 'when the survey has an un-applied edit' do
    before do
      described_class.update_attributes(survey, name: "This is a test")
    end

    describe '.latest' do
      it 'returns that edit' do
        expect(described_class.latest(survey)).to eq survey.edits.order(created_at: :desc).first
      end
    end

    describe '.present?' do
      it 'is true' do
        expect(described_class).to be_present(survey)
      end
    end
  end
end
