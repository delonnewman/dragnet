# frozen_string_literal: true

describe Dragnet::Reply::AnswersCache do
  subject(:cache) { reply.answers_cache }

  let(:reply) { Dragnet::Reply[survey:].generate }
  let(:survey) { Dragnet::Survey.generate! }

  it 'builds answers from cached data' do
    reply.save!

    expect { cache.answers }.to perform_number_of_queries(0)
  end
end
