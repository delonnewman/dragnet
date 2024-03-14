require 'rails_helper'

describe Dragnet::SurveyEdit do
  subject(:edit) { described_class[survey_data:].generate! }

  let(:survey_data) { Dragnet::Survey[author:].generate!.projection }
  let(:author) { Dragnet::User.generate! }

  context 'when survey data is valid' do
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

  context 'when the survey data is invalid' do
    let(:survey_data) { {} }

    describe '#applied!' do
      it 'raises an error' do
        expect { edit.applied! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    describe '#apply!' do
      it 'raises an error' do
        expect { edit.apply! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
