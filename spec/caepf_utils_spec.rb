require 'spec_helper'

RSpec.describe BrazilianUtils::CAEPFUtils do
  describe '.is_valid' do
    it 'validates a masked CAEPF' do
      expect(described_class.is_valid('293.118.610/001-84')).to be true
    end

    it 'validates the same value unmasked' do
      expect(described_class.is_valid('29311861000184')).to be true
    end

    it 'validates another CAEPF' do
      expect(described_class.is_valid('41142260000101')).to be true
    end

    it 'rejects a wrong check digit' do
      expect(described_class.is_valid('29311861000185')).to be false
    end

    it 'rejects an all-zero base' do
      expect(described_class.is_valid('00000000000000')).to be false
    end

    it 'rejects a too-short value' do
      expect(described_class.is_valid('1234567890')).to be false
    end

    it 'rejects letters' do
      expect(described_class.is_valid('abc.118.610/001-84')).to be false
    end

    it 'rejects an empty string' do
      expect(described_class.is_valid('')).to be false
    end
  end

  describe '.format' do
    it 'masks a 14-digit value' do
      expect(described_class.format('29311861000184')).to eq('293.118.610/001-84')
    end

    it 'is idempotent on an already-formatted value' do
      expect(described_class.format('293.118.610/001-84')).to eq('293.118.610/001-84')
    end

    it 'masks a partial value as far as it goes' do
      expect(described_class.format('2931')).to eq('293.1')
    end

    it 'returns an empty string for empty input' do
      expect(described_class.format('')).to eq('')
    end
  end

  describe '.parse' do
    it 'removes the mask' do
      expect(described_class.parse('293.118.610/001-84')).to eq('29311861000184')
    end

    it 'strips non-digit characters' do
      expect(described_class.parse('293.?ABC118.610/001-84abc')).to eq('29311861000184')
    end

    it 'returns an empty string for empty input' do
      expect(described_class.parse('')).to eq('')
    end

    it 'caps the result to 14 characters' do
      expect(described_class.parse('29311861000184999')).to eq('29311861000184')
    end
  end
end
