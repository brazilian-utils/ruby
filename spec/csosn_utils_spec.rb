require 'spec_helper'

RSpec.describe BrazilianUtils::CSOSNUtils do
  describe '.is_valid' do
    it 'validates "101"' do
      expect(described_class.is_valid('101')).to be true
    end

    it 'validates "102"' do
      expect(described_class.is_valid('102')).to be true
    end

    it 'rejects a nonexistent code' do
      expect(described_class.is_valid('999')).to be false
    end

    it 'rejects a too-short value' do
      expect(described_class.is_valid('10')).to be false
    end

    it 'rejects a value with a separator' do
      expect(described_class.is_valid('1-01')).to be false
    end

    it 'rejects letters' do
      expect(described_class.is_valid('abc')).to be false
    end

    it 'rejects an empty string' do
      expect(described_class.is_valid('')).to be false
    end

    it 'accepts an integer' do
      expect(described_class.is_valid(101)).to be true
    end
  end

  describe '.list' do
    it 'returns all 10 official CSOSN codes' do
      expect(described_class.list.size).to eq(10)
    end
  end
end
