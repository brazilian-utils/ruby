require 'spec_helper'

RSpec.describe BrazilianUtils::IEUtils do
  describe '.is_valid' do
    it 'accepts a 12-digit SP registration' do
      expect(described_class.is_valid('110042490114', 'SP')).to be true
    end

    it 'accepts an 8-digit RJ registration' do
      expect(described_class.is_valid('12345678', 'RJ')).to be true
    end

    it 'accepts an SP produtor rural registration (P + 12 digits)' do
      expect(described_class.is_valid('P123456789012', 'SP')).to be true
    end

    it 'accepts an 11-digit MT registration' do
      expect(described_class.is_valid('12345678901', 'MT')).to be true
    end

    it 'accepts one of BA\'s two valid lengths (9 digits)' do
      expect(described_class.is_valid('123456789', 'BA')).to be true
    end

    it 'is case-insensitive on the UF' do
      expect(described_class.is_valid('12345678', 'rj')).to be true
    end

    it 'accepts a masked value' do
      expect(described_class.is_valid('110.042.490.114', 'SP')).to be true
    end

    it 'rejects the wrong length for the state' do
      expect(described_class.is_valid('123456789', 'SP')).to be false
    end

    it 'rejects an unknown UF' do
      expect(described_class.is_valid('123456789', 'XX')).to be false
    end

    it 'rejects empty input' do
      expect(described_class.is_valid('', 'SP')).to be false
    end

    it 'rejects non-digit characters other than the SP producer-rural prefix' do
      expect(described_class.is_valid('12345678a', 'RJ')).to be false
    end
  end

  describe '.valid?' do
    it 'is an alias for is_valid' do
      expect(described_class.valid?('12345678', 'RJ')).to be true
    end
  end
end
