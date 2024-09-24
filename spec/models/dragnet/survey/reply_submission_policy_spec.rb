# frozen_string_literal: true

describe Dragnet::Survey::ReplySubmissionPolicy do
  subject(:policy) { described_class.new(survey) }

  let(:survey) { Dragnet::Survey[author:].generate! }
  let(:author) { Dragnet::User.generate! }
  let(:other_user) { Dragnet::User.generate! }

  include_examples 'user reply submission'
end
