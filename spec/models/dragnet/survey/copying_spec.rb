require 'rails_helper'

describe Dragnet::Survey::Copying do
  subject(:copying) { described_class.new(survey) }

  describe '#copy_data' do
    let(:survey) { Dragnet::Survey.generate!(questions: { question_type: question_type }) }
    let(:question_type) { Dragnet::QuestionType.create!(name: 'Choice') }

    it 'will remove survey id' do
      expect(copying.copy_data).not_to have_key(:id)
    end

    it 'will remove question ids' do
      copying.copy_data[:questions_attributes].each do |question|
        expect(question).not_to have_key(:id)
      end
    end

    it 'will remove question option ids' do
      copying.copy_data[:questions_attributes].each do |question|
        question[:question_options_attributes].each do |question_option|
          expect(question_option).not_to have_key(:id)
        end
      end
    end
  end
end
