require 'rails_helper'

# TODO: move this to a concern spec don't use shared spec
RSpec.describe Survey, type: :model do
  describe '#new' do
    context 'when no slug is given' do
      subject(:survey) { Survey.new(name: Name.generate) }

      it 'will generate a slug' do
        expect(survey.slug).to eq Dragnet::Utils.slug(survey.name)
      end
    end

    context 'when slug is given' do
      subject(:survey) { Survey.new(name: Name.generate, slug: 'testing-123') }

      it 'will use the given slug' do
        expect(survey.slug).to eq 'testing-123'
      end
    end
  end
end
