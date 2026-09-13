# frozen_string_literal: true

describe Dragnet::Reply::AnswersCache do
  subject(:cache) { reply.answers_cache }

  let(:reply) { Dragnet::Reply[survey:].generate }
  let(:survey) { Dragnet::Survey.generate! }
end
