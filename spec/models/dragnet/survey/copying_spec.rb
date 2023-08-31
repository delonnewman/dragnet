require 'rails_helper'

describe Dragnet::Survey::Copying do
  subject(:copying) { described_class.new(survey) }

  describe '#copy_data' do
    context 'when survey has no questions' do
      let(:survey) { Dragnet::Survey[id: Dragnet::UUID].generate(questions: { count: 0 }) }

      it 'will remove survey id' do
        expect(copying.copy_data).not_to have_key(:id)
      end
    end

    context 'when survey has questions' do
      let(:survey) { Dragnet::Survey[id: Dragnet::UUID].generate(questions: { question_type: question_type }) }
      let(:question_type) { Dragnet::QuestionType.create!(name: 'Choice') }

      it 'will remove survey id' do
        expect(copying.copy_data).not_to have_key(:id)
      end

      it 'will remove question ids'
      it 'will remove question option ids'
    end
  end
end
