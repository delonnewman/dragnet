require 'rails_helper'

RSpec.describe Dragnet::DataGrid do
  let!(:user) { Dragnet::User.generate! }
  let!(:survey) { Dragnet::Survey.generate! }

  describe 'whole value' do
    before do
      described_class[survey:, user:].generate!
    end

    it "loads all of a survey's componets in one query when the whole value is not requested" do
      relation = described_class.whole

      expect { walking_graph(relation.first) }.to perform_number_of_queries(2)
    end

    it "loads each of a survey's components separately when the whole value is not requested" do
      expect { walking_graph(described_class.first) }.not_to perform_number_of_queries(2)
    end

    def walking_graph(relation)
      relation.survey
      relation.questions.each do |question|
        question.question_type
        question.question_options.load
      end
    end
  end
end
