require 'rails_helper'

RSpec.describe Dragnet::Survey::EditingStatus do
  let(:survey) { Dragnet::Survey.generate! }

  it 'assigns a default editing status' do
    survey.update_columns(edits_status: nil) # skip callabacks

    expect { described_class.assign_default!(survey) }.to change(survey, :edits_saved?).from(false).to(true)
  end
end
