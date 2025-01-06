require 'rails_helper'

RSpec.describe Dragnet::DataGrid do
  let(:user) { Dragnet::User.generate! }
  let(:survey) { Dragnet::Survey[author: user].generate! }

  describe '.find_or_create!' do
    it "creates a new grid if one doesn't already exist" do
      grid = described_class.find_or_create!(survey, user:)

      expect(grid).to be_previously_new_record
    end

    it 'loads the existing grid if one has already been created' do
      described_class.create!(user:, survey:)
      grid = described_class.find_or_create!(survey, user:)

      expect(grid).to be_persisted
    end
  end

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
        question.question_options.load
      end
    end
  end
end
