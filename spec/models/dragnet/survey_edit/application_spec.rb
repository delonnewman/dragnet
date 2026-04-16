require 'rails_helper'

describe Dragnet::SurveyEdit do
  subject(:edit) { described_class.update_attributes(survey, name: "This is a test") }

  let(:survey) { Dragnet::Survey[author:].generate! }
  let(:author) { Dragnet::User.generate! }

  describe '#applied!' do
    it 'sets SurveyEdit#applied to true' do
      expect(edit.applied!).to be_applied
    end

    it 'sets SurveyEdit#applied_at to the timestamp' do
      timestamp = Time.zone.now

      expect(edit.applied!(timestamp).applied_at).to eq(timestamp)
    end
  end
end
