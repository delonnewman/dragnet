# frozen_string_literal: true

describe Dragnet::Reply::AnswersCache do
  subject(:cache) { described_class.new(reply) }

  let(:reply) { Dragnet::Reply[survey:].generate }
  let(:survey) { Dragnet::Survey.generate! }

  it 'can be set' do
    expect { cache.set! }.to change(cache, :data).from(nil)
  end

  it "raises an error when answers are requested if there's no data in the cache" do
    expect { cache.answers }.to raise_error(/No data in cache/)
  end

  it 'builds answers from cached data' do
    cache.set!

    expect { cache.answers }.to perform_number_of_queries(0)
  end
end
