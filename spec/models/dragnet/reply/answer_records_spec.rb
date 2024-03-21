require 'rails_helper'

RSpec.describe Dragnet::Reply::AnswerRecords do
  let(:reply) { Dragnet::Reply[survey:].generate!(question_type:) }
  let(:question_type) { QuestionType.get(:choice) }
  let(:survey) { Dragnet::Survey.generate! }

  describe '.attributes' do
    it 'does not run any queries' do
      answer_data = described_class.new(reply).data

      expect { described_class.attributes(answer_data) }
        .to perform_number_of_queries 0
    end
  end
end
