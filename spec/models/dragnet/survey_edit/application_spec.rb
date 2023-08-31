require 'rails_helper'

describe Dragnet::SurveyEdit::Application do
  subject(:application) { described_class.new(edit) }

  let(:author) { Dragnet::User.generate! }
  let(:survey_data) { Dragnet::Survey[author: author].generate!.projection }
  let(:edit) { Dragnet::SurveyEdit[survey_data: survey_data].generate! }

  context 'when survey data is valid' do
    describe '#applied!' do
      it 'will set SurveyEdit#applied to true' do
        expect(application.applied!).to be_applied
      end

      it 'will set SurveyEdit#applied_at to the timestamp' do
        timestamp = Time.zone.now

        expect(application.applied!(timestamp).applied_at).to eq(timestamp)
      end
    end

    xdescribe '#apply!' do
      it 'will apply the edit to the survey' do
        expect(application.apply!).to eq(Survey.new(edit.survey_attributes))
      end

      it 'will set SurveyEdit#applied to true' do
        application.apply!

        expect(edit).to be_applied
      end

      it 'will set SurveyEdit#applied_at to the timestamp' do
        timestamp = Time.zone.now
        application.apply!(timestamp)

        expect(edit.applied_at).to eq(timestamp)
      end

      it 'will change the survey update timestamp' do
        updated_at = edit.survey.updated_at

        expect(application.apply!.updated_at).not_to eq(updated_at)
      end
    end
  end

  context 'when the survey data is invalid' do
    let(:survey_data) { {} }

    describe '#applied!' do
      it 'will raise an error' do
        expect { application.applied! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    describe '#apply!' do
      it 'will raise an error' do
        expect { application.apply! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end