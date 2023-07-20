# frozen_string_literal: true

describe Dragnet::TimeUtils do
  describe '.fmt_hour' do
    it 'returns 12 AM for 0' do
      expect(described_class.fmt_hour(0)).to eq '12 AM'
    end

    it 'returns 12 AM for 24' do
      expect(described_class.fmt_hour(24)).to eq '12 AM'
    end

    it 'returns 12 PM for 12' do
      expect(described_class.fmt_hour(12)).to eq '12 PM'
    end

    it 'returns N AM where N is between 1 and 11' do
      (1..11).each do |n|
        expect(described_class.fmt_hour(n)).to eq "#{n} AM"
      end
    end
  end
end
