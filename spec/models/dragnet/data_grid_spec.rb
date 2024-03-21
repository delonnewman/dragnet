require 'rails_helper'

RSpec.describe Dragnet::DataGrid do
  let!(:user) { Dragnet::User.generate! }
  let!(:survey) { Dragnet::Survey.generate! }

  describe '.whole' do
    before do
      described_class[survey:, user:].generate!
    end

    it "loads all of a survey's componets in one query" do
      relation = described_class.whole

      expect { relation.first.tap { |g| g.survey; g.questions.each { |q| q.question_type; q.question_options.load } } }
        .to perform_number_of_queries(2) # performs a prefetch query
    end
  end
end
