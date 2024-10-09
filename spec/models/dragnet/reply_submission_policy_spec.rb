# frozen_string_literal: true

describe Dragnet::ReplySubmissionPolicy do
  subject(:policy) { described_class.new(reply) }

  let(:reply) { Dragnet::Reply[survey:].generate! }
  let(:survey) { Dragnet::Survey[author:].generate! }
  let(:author) { Dragnet::User.generate! }
  let(:other_user) { Dragnet::User.generate! }

  it 'permits authors to submit replies to their surveys' do
    expect(policy).to be_can_submit_reply(author)
  end

  it 'permits any user to submit replies to public surveys' do
    survey.public = true

    expect(policy).to be_can_submit_reply(other_user)
  end

  it 'permits any user to submit replies to private surveys that are open' do
    survey.opened!

    expect(policy).to be_can_submit_reply(other_user)
  end

  it "doesn't permit users who aren't authors who to submit replies to closed private surveys" do
    survey.public = false
    survey.closed!

    expect(policy).not_to be_can_submit_reply(other_user)
  end

  it "doesn't permit users who can't submit to edit" do
    survey.public = false
    survey.closed!

    expect(policy).not_to be_can_edit_reply(other_user)
  end

  it "doesn't permit editing of replies that are expired" do
    survey.opened!
    reply.submitted = false
    reply.submitted_at = nil
    reply.expires_at = Time.zone.now

    expect(policy).not_to be_can_edit_reply(other_user)
  end
end
