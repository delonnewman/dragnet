# frozen_string_literal: true

describe Dragnet::Survey do
  subject(:survey) { described_class.whole.create!(name:, author:) }

  let(:name) { Dragnet::Generators::Name.generate }
  let(:author) { Dragnet::User.generate! }

  it_behaves_like Dragnet::SelfDescribable do
    let(:self_describable) { survey }
  end

  it_behaves_like Dragnet::Retractable do
    let(:retractable) { survey }
  end

  describe '.whole' do
    before do
      described_class.generate!
    end

    it "loads all of a survey's componets in one query" do
      relation = described_class.whole

      expect { relation.first.questions.each { |q| q.question_type; q.question_options.load } }
        .to perform_number_of_queries(2) # performs a prefetch query
    end
  end

  describe '#save' do
    it 'sets the edit status to :saved when no edit status is given' do
      expect(survey).to be_edits_saved
    end

    it 'sets the edit status to the given status when an edit staqtus is given' do
      survey = described_class.create!(name:, edits_status: 'unsaved', author:)

      expect(survey.edits_status).to eq('unsaved')
    end
  end

  describe 'Naming' do
    it 'generates a slug when no slug is given' do
      survey = described_class.create!(name:, slug: '', author:)

      expect(survey.slug).to eq Dragnet::Utils.slug(survey.name)
    end

    it 'uses the given slug when a slug is given' do
      survey = described_class.create!(name:, slug: 'testing-123', author:)

      expect(survey.slug).to eq 'testing-123'
    end

    it 'uses the given name when a name is given' do
      survey = described_class.create!(name: 'testing-123', author:)

      expect(survey.name).to eq 'testing-123'
    end

    it 'generates a name when no name is given' do
      survey = described_class.create!(name: '', author:)

      expect(survey.name).not_to be_blank
    end

    it 'generates a unique name if a survey by the same author already has a generated name' do
      survey_names = Array.new(10) { described_class.create!(name: '', author:) }.map(&:name).uniq

      expect(survey_names.count).to be 10
    end

    it 'generates the same name if a survey by a different author already has a generated name' do
      survey1 = described_class.create!(name: '', author:)
      survey2 = described_class.create!(name: '', author: User.generate!)

      expect(survey2.name).to eq survey1.name
    end
  end

  describe 'Visit Tracking' do
    subject(:survey) { described_class.generate! }

    let(:reply) { Dragnet::Reply[survey:].generate! }
    let(:ahoy) { Ahoy::Tracker.new }
    let(:tracker) { Dragnet::ReplyTracker.new(ahoy) }

    before do
      ahoy.track_visit
    end

    it 'knows when a reply has been created for a survey by a visitor' do
      tracker.view_submission_form(reply)

      expect(survey).to be_reply_created(ahoy.visitor_token)
    end

    it 'knows when a reply has not be created for a survey by a visitor' do
      expect(survey).not_to be_reply_created(ahoy.visitor_token)
    end

    it 'knows when a reply has been completed for a survey by a visitor' do
      Dragnet::Reply[survey:, submitted: true, ahoy_visit: ahoy.visit].generate!

      expect(survey).to be_reply_completed(ahoy.visitor_token)
    end

    it 'can find an existing reply for a visitor if one exists' do
      reply = Dragnet::Reply[survey:, ahoy_visit: ahoy.visit].generate!

      expect(survey.existing_reply(ahoy.visitor_token)).to eq(reply)
    end

    it "returns nil if a reply doesn't for a visitor exist when asked" do
      expect(survey.existing_reply(ahoy.visitor_token)).to be_nil
    end
  end
end
