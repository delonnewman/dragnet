require 'rails_helper'

describe Dragnet::Survey::Copy do
  describe '.data' do
    let(:survey) { Dragnet::Survey.generate!(questions: { type_class: }) }
    let(:type_class) { Dragnet::Types::Choice }
    let(:data) { described_class.data(survey) }

    it 'removes survey id' do
      expect(data).not_to have_key(:id)
    end

    it 'removes question ids' do
      data[:questions_attributes].each do |question|
        expect(question).not_to have_key(:id)
      end
    end

    it 'removes question option ids' do
      data[:questions_attributes].each do |question|
        question[:question_options_attributes].each do |question_option|
          expect(question_option).not_to have_key(:id)
        end
      end
    end
  end
end
