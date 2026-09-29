require 'spec_helper'

RSpec.describe BrazilianUtils::CNSUtils do
  describe '.is_valid' do
    it 'validates a definitive CNS' do
      expect(described_class.is_valid('123456789010000')).to be true
    end

    it 'accepts the masked form' do
      expect(described_class.is_valid('123 4567 8901 0000')).to be true
    end

    it 'validates a provisional CNS' do
      expect(described_class.is_valid('898000000043208')).to be true
    end

    it 'validates a provisional CNS starting with 7' do
      expect(described_class.is_valid('700000000000005')).to be true
    end

    it 'rejects a wrong check digit' do
      expect(described_class.is_valid('123456789010001')).to be false
    end

    it 'rejects an invalid first digit' do
      expect(described_class.is_valid('312345678901234')).to be false
    end

    it 'rejects a too-short value' do
      expect(described_class.is_valid('12345678901')).to be false
    end

    it 'rejects an empty string' do
      expect(described_class.is_valid('')).to be false
    end
  end

  describe '.format' do
    it 'groups a 15-digit value as 3-4-4-4' do
      expect(described_class.format('123456789010001')).to eq('123 4567 8901 0001')
    end

    it 'is idempotent on an already-formatted value' do
      expect(described_class.format('898 0000 0004 3208')).to eq('898 0000 0004 3208')
    end

    it 'masks a partial value as far as it goes' do
      expect(described_class.format('1234')).to eq('123 4')
    end

    it 'returns an empty string for empty input' do
      expect(described_class.format('')).to eq('')
    end
  end

  describe '.parse' do
    it 'removes the mask' do
      expect(described_class.parse('123 4567 8901 0000')).to eq('123456789010000')
    end

    it 'strips non-digit characters' do
      expect(described_class.parse('123.?ABC4567 8901-0000abc')).to eq('123456789010000')
    end

    it 'returns an empty string for empty input' do
      expect(described_class.parse('')).to eq('')
    end

    it 'caps the result to 15 characters' do
      expect(described_class.parse('123456789010000999')).to eq('123456789010000')
    end
  end
end
