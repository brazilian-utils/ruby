require 'spec_helper'

RSpec.describe BrazilianUtils::CreditCardUtils do
  describe '.is_valid' do
    it 'validates a Visa test number' do
      expect(described_class.is_valid('4111111111111111')).to be true
    end

    it 'validates a Mastercard test number' do
      expect(described_class.is_valid('5555555555554444')).to be true
    end

    it 'validates a 15-digit Amex-style number' do
      expect(described_class.is_valid('378282246310005')).to be true
    end

    it 'accepts a masked number' do
      expect(described_class.is_valid('4111 1111 1111 1111')).to be true
    end

    it 'rejects a Luhn failure' do
      expect(described_class.is_valid('4111111111111112')).to be false
    end

    it 'rejects an all-zero number' do
      expect(described_class.is_valid('0000000000000000')).to be false
    end

    it 'rejects a too-short number' do
      expect(described_class.is_valid('60110000000')).to be false
    end

    it 'rejects letters' do
      expect(described_class.is_valid('abcdabcdabcd')).to be false
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
