# frozen_string_literal: true

describe Dragnet::Question do
  subject(:question) { described_class[survey: survey].generate! }
  let(:survey) { Dragnet::Survey.generate! }

  it_behaves_like Dragnet::SelfDescribable do
    let(:self_describable) { question }
  end

  it_behaves_like Dragnet::Retractable do
    let(:retractable) { question }
  end
end
