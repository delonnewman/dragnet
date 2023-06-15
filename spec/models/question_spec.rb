# frozen_string_literal: true

require_relative 'self_describable'

describe Question do
  it_behaves_like 'self describable' do
    let(:self_describable) { described_class[survey: survey].generate! }
    let(:survey) { Survey.generate! }
  end
end
