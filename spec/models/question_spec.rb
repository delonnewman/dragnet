# frozen_string_literal: true

require_relative 'self_describable'
require_relative 'retractable'

describe Question do
  subject(:question) { described_class[survey: survey].generate! }
  let(:survey) { Survey.generate! }

  it_behaves_like SelfDescribable do
    let(:self_describable) { question }
  end

  it_behaves_like Retractable do
    let(:retractable) { question }
  end
end
