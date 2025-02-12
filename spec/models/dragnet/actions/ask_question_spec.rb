describe Dragnet::Actions::AskQuestion do
  subject(:prompt) { described_class.new(question:) }

  let(:question) { Dragnet::Question[survey:].generate! }
  let(:survey) { Dragnet::Survey.generate! }

  it_behaves_like Dragnet::Resumable do
    let(:resumable) { prompt }
  end

  it_behaves_like 'an action' do
    let(:action) { prompt }
  end

  it "must be given a question when it's created" do
    expect { described_class.new({}) }.to raise_error(/a question is required/)
  end
end
