# frozen_string_literal: true

describe Dragnet::QuestionType do
  it_behaves_like Dragnet::SelfDescribable do
    let(:self_describable) { described_class.generate! }
  end
end
