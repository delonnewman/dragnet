require 'rails_helper'

RSpec.describe Dragnet::Answer::DoBeforeSaving do
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
