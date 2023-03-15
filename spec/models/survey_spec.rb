require 'rails_helper'
require_relative 'self_describable'

describe Survey, type: :model do
  it_behaves_like :self_describable do
    let(:self_describable) { described_class.create!(name: name, author: author) }
    let(:name) { Dragnet::Generators::Name.generate }
    let(:author) { User.generate! }
  end

  describe '#new' do
    subject(:survey) { described_class.create!(name: name, author: author) }

    let(:name) { Dragnet::Generators::Name.generate }
    let(:author) { User.generate! }

    context 'when no slug is given' do
      it 'will generate a slug' do
        expect(survey.slug).to eq Dragnet::Utils.slug(survey.name)
      end
    end

    context 'when slug is given' do
      subject(:survey) { described_class.create!(name: name, slug: 'testing-123', author: author) }

      it 'will use the given slug' do
        expect(survey.slug).to eq 'testing-123'
      end
    end

    context 'when a name is given' do
      it 'will use the given name' do
        expect(survey.name).to eq name
      end
    end

    context 'when no name is given' do
      let(:name) { nil }

      it 'will generate a name' do
        expect(survey.name).not_to be_blank
      end
    end
  end
end
