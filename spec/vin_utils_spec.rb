require 'spec_helper'

RSpec.describe BrazilianUtils::VINUtils do
  describe '.is_valid' do
    it 'validates a known-good VIN' do
      expect(described_class.is_valid('1HGCM82633A004352')).to be true
    end

    it 'validates a VIN whose check digit is X' do
      expect(described_class.is_valid('1M8GDM9AXKP042788')).to be true
    end

    it 'is case-insensitive' do
      expect(described_class.is_valid('1m8gdm9axkp042788')).to be true
    end

    it 'rejects a wrong check digit' do
      expect(described_class.is_valid('1HGCM82633A004353')).to be false
    end

    it 'rejects the excluded letter I' do
      expect(described_class.is_valid('1HGCM8263IA004352')).to be false
    end

    it 'rejects a too-short value' do
      expect(described_class.is_valid('1HGCM82633A00435')).to be false
    end

    it 'rejects a value whose characters are all the same' do
      expect(described_class.is_valid('00000000000000000')).to be false
    end

    it 'rejects an empty string' do
      expect(described_class.is_valid('')).to be false
    end
  end

  describe '.valid?' do
    it 'is an alias for is_valid' do
      expect(described_class.method(:valid?)).to eq(described_class.method(:is_valid))
    end
  end
end
