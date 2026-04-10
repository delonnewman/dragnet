require 'rails_helper'

RSpec.describe Dragnet::Survey::EditingStatus do
  let(:survey) { Dragnet::Survey.generate! }

  it 'assigns a default editing status' do
    survey.editing_status = nil # skip callbacks

    expect { described_class.assign_default!(survey) }
      .to change(survey, :editing_status).from(nil).to(described_class.published)
  end
end
