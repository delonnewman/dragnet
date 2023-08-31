# frozen_string_literal: true

shared_examples Dragnet::Retractable do
  describe '#retracted!' do
    it 'will flag retracted as true' do
      expect { retractable.retracted! }
        .to change { retractable.retracted? }.from(false).to(true)
    end

    it 'will set the retracted_at timestamp' do
      expect { retractable.retracted! }
        .to change { retractable.retracted_at }.from(nil)
    end

    it 'will mark all retractable associated records as retracted' do
      retractable.retracted!

      retractable.class.retractable_associations.each do |association|
        retractable.public_send(association).each do |record|
          expect(record).to be_retracted
          expect(record.retracted_at).not_to be_nil
        end
      end
    end
  end
end
