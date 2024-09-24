# frozen_string_literal: true

describe Dragnet::Survey::ReplySubmissionPolicy do
  subject(:policy) { described_class.new(survey) }

  let(:survey) { Dragnet::Survey[author:].generate! }
  let(:author) { Dragnet::User.generate! }
  let(:other_user) { Dragnet::User.generate! }

  it 'permits authors to submit replies to their surveys' do
    expect(policy).to be_user_can_submit_reply(author)
  end

  it 'permits any user to submit replies to public surveys' do
    survey.public = true

    expect(policy).to be_user_can_submit_reply(other_user)
  end

  it 'permits any user to submit replies to private surveys that are open' do
    survey.opened!

    expect(policy).to be_user_can_submit_reply(other_user)
  end
end
