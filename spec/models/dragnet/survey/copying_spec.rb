require 'rails_helper'

describe Dragnet::Survey do
  describe '#copy_data' do
    let(:survey) { described_class.generate!(questions: { question_type: }) }
    let(:question_type) { Dragnet::QuestionType.create!(name: 'Choice') }

    it 'removes survey id' do
      expect(survey.copy_data).not_to have_key(:id)
    end

    it 'removes question ids' do
      survey.copy_data[:questions_attributes].each do |question|
        expect(question).not_to have_key(:id)
      end
    end

    it 'removes question option ids' do
      survey.copy_data[:questions_attributes].each do |question|
        question[:question_options_attributes].each do |question_option|
          expect(question_option).not_to have_key(:id)
        end
      end
    end
  end
end
