require 'spec_helper'

RSpec.describe BrazilianUtils::CEIUtils do
  describe '.is_valid' do
    it 'validates a masked CEI' do
      expect(described_class.is_valid('11.583.00249/85')).to be true
    end

    it 'validates the same value unmasked' do
      expect(described_class.is_valid('115830024985')).to be true
    end

    it 'validates another CEI' do
      expect(described_class.is_valid('277297118187')).to be true
    end

    it 'rejects a wrong check digit' do
      expect(described_class.is_valid('115830024984')).to be false
    end

    it 'rejects an all-zero value' do
      expect(described_class.is_valid('000000000000')).to be false
    end

    it 'rejects a too-short value' do
      expect(described_class.is_valid('1234567890')).to be false
    end

    it 'rejects letters' do
      expect(described_class.is_valid('aa.583.00249/85')).to be false
    end

    it 'rejects an empty string' do
      expect(described_class.is_valid('')).to be false
    end
  end

  describe '.format' do
    it 'masks a 12-digit value' do
      expect(described_class.format('277297118187')).to eq('27.729.71181/87')
    end

    it 'is idempotent on an already-formatted value' do
      expect(described_class.format('11.583.00249/85')).to eq('11.583.00249/85')
    end

    it 'masks a partial value as far as it goes' do
      expect(described_class.format('27729')).to eq('27.729')
    end

    it 'returns an empty string for empty input' do
      expect(described_class.format('')).to eq('')
    end
  end

  describe '.parse' do
    it 'removes the mask' do
      expect(described_class.parse('27.729.71181/87')).to eq('277297118187')
    end

    it 'strips non-digit characters' do
      expect(described_class.parse('27.?ABC729.71181/87abc')).to eq('277297118187')
    end

    it 'returns an empty string for empty input' do
      expect(described_class.parse('')).to eq('')
    end

    it 'caps the result to 12 characters' do
      expect(described_class.parse('277297118187999')).to eq('277297118187')
    end
  end
end
