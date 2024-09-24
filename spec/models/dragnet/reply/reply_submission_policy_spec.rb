describe Dragnet::Reply::ReplySubmissionPolicy do
  subject(:policy) { described_class.new(reply) }

  let(:reply) { Dragnet::Reply[survey:].generate! }
  let(:survey) { Dragnet::Survey[author:].generate! }
  let(:author) { Dragnet::User.generate! }
  let(:other_user) { Dragnet::User.generate! }

  include_examples 'user reply submission'

  it "doesn't permit users who can't submit to edit" do
    survey.public = false
    survey.closed!

    expect(policy).not_to be_can_edit_reply(other_user)
  end
end
