require 'spec_helper'

RSpec.describe BrazilianUtils::PassportUtils do
  describe '.format' do
    it 'keeps an already-formatted number unchanged' do
      expect(described_class.format('AB123456')).to eq('AB123456')
    end

    it 'upper-cases a lowercase number' do
      expect(described_class.format('acd12736')).to eq('ACD12736')
    end

    it 'strips symbols' do
      expect(described_class.format('AB-123.456')).to eq('AB123456')
    end

    it 'keeps a partial value as-is' do
      expect(described_class.format('AB12')).to eq('AB12')
    end

    it 'returns an empty string for empty input' do
      expect(described_class.format('')).to eq('')
    end

    it 'caps the result to 8 characters' do
      expect(described_class.format('AB123456789')).to eq('AB123456')
    end
  end

  describe '.is_valid' do
    it 'validates a well-formed number' do
      expect(described_class.is_valid('AA111111')).to be true
    end

    it 'validates another well-formed number' do
      expect(described_class.is_valid('CL125167')).to be true
    end

    it 'is case-insensitive' do
      expect(described_class.is_valid('ab123456')).to be true
    end

    it 'accepts a masked value' do
      expect(described_class.is_valid('AB-123456')).to be true
    end

    it 'accepts a dotted value' do
      expect(described_class.is_valid('AB.123.456')).to be true
    end

    it 'rejects a single digit' do
      expect(described_class.is_valid('1')).to be false
    end

    it 'rejects a number-only value' do
      expect(described_class.is_valid('1112223334-')).to be false
    end

    it 'rejects a numeric input' do
      expect(described_class.is_valid(1)).to be false
    end
  end

  describe '.valid?' do
    it 'is an alias for is_valid' do
      expect(described_class.method(:valid?)).to eq(described_class.method(:is_valid))
    end
  end

  describe '.parse' do
    it 'upper-cases and removes nothing else needed' do
      expect(described_class.parse('Ab123456')).to eq('AB123456')
    end

    it 'removes spaces' do
      expect(described_class.parse(' AB 123 456 ')).to eq('AB123456')
    end

    it 'removes hyphens' do
      expect(described_class.parse('-AB1-23-4-56-')).to eq('AB123456')
    end

    it 'caps the result to 8 characters' do
      expect(described_class.parse('AB123456789')).to eq('AB123456')
    end

    it 'returns an empty string for empty input' do
      expect(described_class.parse('')).to eq('')
    end
  end

  describe '.remove_symbols' do
    it 'removes hyphens, dots and whitespace' do
      expect(described_class.remove_symbols('AB-123.456')).to eq('AB123456')
    end
  end

  describe '.generate' do
    it 'generates a value that passes .is_valid' do
      5.times do
        passport = described_class.generate
        expect(described_class.is_valid(passport)).to be true
      end
    end
  end
end
