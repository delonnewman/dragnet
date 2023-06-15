# frozen_string_literal: true

describe Survey::Naming do
  subject(:naming) { described_class.new(survey, default_name) }

  let(:default_name) { 'New Survey' }
  let(:survey) { Survey.new(author: author) }
  let(:author) { User.generate }

  describe '#auto_named?' do
    let(:survey) { Survey.new(author: author, name: name) }

    context 'when a name is given that does not start with the default name' do
      let(:name) { Dragnet::Generators::Name.generate }

      it { is_expected.not_to be_auto_named }
    end

    context 'when a name is given that starts with the default name' do
      let(:name) { "#{default_name} #{Dragnet::Generators::Name.generate}" }

      it { is_expected.to be_auto_named }
    end
  end

  describe '#generate_name?' do
    let(:survey) { Survey.new(author: author, name: name) }

    context 'when survey is new or will save a change to author_id' do
      context 'when a name is not given' do
        let(:name) { nil }

        it { is_expected.to be_generated_name }
      end

      context 'when a name is given' do
        let(:name) { Dragnet::Generators::Name.generate }

        it { is_expected.not_to be_generated_name }
      end

      context 'when a name is given that starts with the default name' do
        let(:name) { "#{default_name} #{Dragnet::Generators::Name.generate}" }

        it { is_expected.to be_generated_name }
      end
    end
  end

  describe '#author_id' do
    context 'when survey has no author or author_id' do
      let(:survey) { Survey.new }

      it 'will return nil' do
        expect(naming.author_id).to be_nil
      end
    end

    context 'when survey has an author' do
      let(:survey) { Survey.new(author: author) }

      it 'will return the author id' do
        expect(naming.author_id).to be author.id
      end
    end

    context 'when survey has an author_id' do
      let(:survey) { Survey.new(author_id: author_id) }
      let(:author_id) { (1..100).to_a.sample }

      it 'will return the author id' do
        expect(naming.author_id).to be author_id
      end
    end
  end

  describe '#unique_name' do
    context 'when the number of auto named surveys is zero' do
      before do
        Survey.delete_all
      end

      it 'will return the default name' do
        expect(naming.unique_name).to eq naming.default_name
      end
    end

    context 'when the number of auto named surveys is non-zero' do
      before do
        (1..3).to_a.sample.times do
          Survey.create!(author: author)
        end
      end

      it 'will return a numbered name' do
        expect(naming.unique_name).to eq naming.numbered_name(naming.auto_named_survey_count)
      end
    end
  end
end
