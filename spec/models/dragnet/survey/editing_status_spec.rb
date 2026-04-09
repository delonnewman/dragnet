require 'rails_helper'

RSpec.describe Dragnet::Survey::EditingStatus do
  let(:survey) { Dragnet::Survey.generate! }

  it 'assigns a default editing status' do
    survey.update_columns(editing_status: nil) # skip callbacks

    expect { described_class.assign_default!(survey) }.to change(survey, :edits_saved?).from(false).to(true)
  end
end
