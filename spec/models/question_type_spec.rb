# frozen_string_literal: true

require_relative 'self_describable'

describe QuestionType do
  it_behaves_like 'self describable' do
    let(:self_describable) { described_class.generate! }
  end
end