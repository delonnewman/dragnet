require 'rails_helper'

describe Survey::Editing do
  let(:author) { User.generate! }
  let(:survey) { Survey.init!(author) }

  subject(:editing) { Survey::Editing.new(survey) }

  context 'when the survey has no un-applied edits' do
    describe '#latest_edit' do
      it 'will return nil' do
        expect(editing.latest_edit).to be_nil
      end
    end

    describe '#current_edit' do
      it 'will return a new edit' do
        expect(editing.current_edit.new_record?).to be(true)
      end
    end

    describe '#edited?' do
      it 'will be false' do
        expect(editing).not_to be_edited
      end
    end
  end

  context 'when the survey has an un-applied edit' do
    before do
      editing.new_edit.save!
    end

    describe '#latest_edit' do
      it 'will return that edit' do
        expect(editing.latest_edit).to eq(editing.current_edit)
      end
    end

    describe '#current_edit' do
      it 'will return the latest edit' do
        expect(editing.current_edit).to eq(editing.latest_edit)
      end
    end

    describe '#edited?' do
      it 'will be true' do
        expect(editing).to be_edited
      end
    end
  end
end