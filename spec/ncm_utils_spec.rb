require 'spec_helper'

RSpec.describe BrazilianUtils::NCMUtils do
  describe '.format' do
    it 'masks an 8-digit code' do
      expect(described_class.format('84713012')).to eq('8471.30.12')
    end

    it 'is idempotent on an already-formatted code' do
      expect(described_class.format('8471.30.12')).to eq('8471.30.12')
    end

    it 'masks a partial code as far as it goes' do
      expect(described_class.format('84713')).to eq('8471.3')
    end

    it 'returns an empty string for empty input' do
      expect(described_class.format('')).to eq('')
    end
  end

  describe '.is_valid' do
    it 'validates "22030000"' do
      expect(described_class.is_valid('22030000')).to be true
    end

    it 'accepts the masked form' do
      expect(described_class.is_valid('2203.00.00')).to be true
    end

    it 'validates a code with a leading zero' do
      expect(described_class.is_valid('01012100')).to be true
    end

    it 'rejects a nonexistent code' do
      expect(described_class.is_valid('12345678')).to be false
    end

    it 'rejects a too-short value' do
      expect(described_class.is_valid('2203000')).to be false
    end

    it 'rejects letters' do
      expect(described_class.is_valid('abcdefgh')).to be false
    end

    it 'rejects an empty string' do
      expect(described_class.is_valid('')).to be false
    end
  end

  describe '.parse' do
    it 'removes the mask' do
      expect(described_class.parse('8471.30.12')).to eq('84713012')
    end

    it 'strips non-digit characters' do
      expect(described_class.parse('84?ABC71.30.12abc')).to eq('84713012')
    end

    it 'returns an empty string for empty input' do
      expect(described_class.parse('')).to eq('')
    end

    it 'caps the result to 8 characters' do
      expect(described_class.parse('84713012999')).to eq('84713012')
    end
  end
end
