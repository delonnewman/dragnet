require 'rails_helper'

RSpec.describe Dragnet::DataGrid::Query do
  subject(:query) { described_class.new(survey.questions, params) }

  let(:survey) { Dragnet::Survey.generate! }
  let(:params) { {} }

  describe '#filtered?' do
    it 'returns true when there are filters' do
      query = described_class.new(survey.questions, { filter_by: { user_id: 1 } })

      expect(query).to be_filtered
    end

    it 'returns false when no filters are present' do
      expect(query).not_to be_filtered
    end
  end

  describe '#sort_by_question?' do
    it 'returns true when the sorting value is a question id' do
      query = described_class.new(survey.questions, { sort_by: survey.questions.first.id })

      expect(query).to be_sort_by_question
    end

    it 'returns false when the sorting value is not a question id' do
      query = described_class.new(survey.questions, { sort_by: :created_at })

      expect(query).not_to be_sort_by_question
    end
  end

  describe '#question?' do
    it 'returns true if the given value is a valid question id' do
      expect(query.question?(survey.questions.first.id)).to be true
    end

    it 'returns false when the given value is not a valid question id' do
      expect(query.question?('some value')).to be false
    end
  end

  describe '#question' do
    it 'returns a question when a valid question id is given' do
      expect(query.question(survey.questions.first.id)).to be_an_instance_of(Dragnet::Question)
    end

    it 'raises an exception if the given value is not a valid question id' do
      expect { query.question('some value') }.to raise_error(/unknown question/)
    end
  end

  describe '#sorted_by_column?' do
    it 'returns true when the sorted_by value is given' do
      query = described_class.new(survey.questions, { sort_by: 'created_at' })

      expect(query).to be_sorted_by_column('created_at')
    end

    it 'returns true when the sorted_by value is given as symbol' do
      query = described_class.new(survey.questions, { sort_by: 'created_at' })

      expect(query).to be_sorted_by_column(:created_at)
    end

    it 'returns true when the question whose id is the sorted by value is given' do
      question = survey.questions.first
      query = described_class.new(survey.questions, { sort_by: question.id })

      expect(query).to be_sorted_by_column(question)
    end

    it 'returns false when the value is not a valid question id' do
      fake_id = SecureRandom.uuid
      query = described_class.new(survey.questions, { sort_by: fake_id })

      expect(query).not_to be_sorted_by_column(survey.questions.first)
    end
  end
end
