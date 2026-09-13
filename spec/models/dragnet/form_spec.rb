# frozen_string_literal: true

describe Dragnet::Form do
  subject(:form) { described_class.create!(name:, author:) }

  let(:name) { Dragnet::Generators::Name.generate }
  let(:author) { Dragnet::User.generate! }

  describe '#records' do
    let!(:submitted_reply)   { Dragnet::Reply[survey: form, submitted: true].generate! }
    let!(:unsubmitted_reply) { Dragnet::Reply[survey: form, submitted: false].generate! }

    it 'includes replies regardless of whether they have been submitted' do
      expect(form.records).to contain_exactly(submitted_reply, unsubmitted_reply)
    end

    it 'differs from Survey#records, which excludes the unsubmitted reply' do
      survey = form.becomes(Dragnet::Survey)

      expect(survey.records).to contain_exactly(submitted_reply)
    end
  end
end
