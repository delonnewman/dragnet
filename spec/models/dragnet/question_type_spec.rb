# frozen_string_literal: true

require_relative 'self_describable'

describe Dragnet::QuestionType do
  it_behaves_like Dragnet::SelfDescribable do
    let(:self_describable) { described_class.generate! }
  end
end
