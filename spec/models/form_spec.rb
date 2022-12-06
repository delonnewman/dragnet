require 'rails_helper'

# TODO: move this to a concern spec don't use shared spec
describe Form, type: :model do
  describe '#new' do
    context 'when no slug is given' do
      subject(:form) { Form.new(name: Dragnet::Generators::Name.generate) }

      it 'will generate a slug' do
        expect(form.slug).to eq Dragnet::Utils.slug(form.name)
      end
    end

    context 'when slug is given' do
      subject(:form) { Form.new(name: Dragnet::Generators::Name.generate, slug: 'testing-123') }

      it 'will use the given slug' do
        expect(form.slug).to eq 'testing-123'
      end
    end
  end
end
