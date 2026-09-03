RSpec.describe Dragnet::Answer do
  subject(:answer) { described_class.create!(survey:, reply:, question:) }

  let(:survey) { Dragnet::Survey.generate! }
  let(:question) { survey.questions.to_a.sample }
  let(:reply) { Dragnet::Reply[survey:].generate }

  it_behaves_like Dragnet::Retractable do
    let(:retractable) { answer }
  end
end
