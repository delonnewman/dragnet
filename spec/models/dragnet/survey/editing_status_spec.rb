require 'rails_helper'

RSpec.describe Dragnet::Survey::EditingStatus do
  let(:survey) { Dragnet::Survey.generate! }

  it 'assigns a default editing status' do
    survey.status = nil # skip callbacks

    expect { described_class.assign_default!(survey) }
      .to change(survey, :status).from(nil).to(described_class.published)
  end
end
