require 'spec_helper'

RSpec.describe BrazilianUtils::CNOUtils do
  describe '.is_valid' do
    it 'validates a CNO' do
      expect(described_class.is_valid('110840168062')).to be true
    end

    it 'accepts the masked form' do
      expect(described_class.is_valid('11.084.01680/62')).to be true
    end

    it 'validates another CNO' do
      expect(described_class.is_valid('401800097960')).to be true
    end

    it 'rejects a wrong check digit' do
      expect(described_class.is_valid('110840168063')).to be false
    end

    it 'rejects an all-zero value' do
      expect(described_class.is_valid('000000000000')).to be false
    end

    it 'rejects a too-short value' do
      expect(described_class.is_valid('1234567890')).to be false
    end

    it 'rejects an empty string' do
      expect(described_class.is_valid('')).to be false
    end
  end

  describe '.format' do
    it 'masks a 12-digit value' do
      expect(described_class.format('111130137368')).to eq('11.113.01373/68')
    end

    it 'is idempotent on an already-formatted value' do
      expect(described_class.format('11.084.01680/62')).to eq('11.084.01680/62')
    end

    it 'masks a partial value as far as it goes' do
      expect(described_class.format('11113')).to eq('11.113')
    end

    it 'returns an empty string for empty input' do
      expect(described_class.format('')).to eq('')
    end
  end

  describe '.parse' do
    it 'removes the mask' do
      expect(described_class.parse('11.113.01373/68')).to eq('111130137368')
    end

    it 'strips non-digit characters' do
      expect(described_class.parse('11.?ABC113.01373/68abc')).to eq('111130137368')
    end

    it 'returns an empty string for empty input' do
      expect(described_class.parse('')).to eq('')
    end

    it 'caps the result to 12 characters' do
      expect(described_class.parse('111130137368999')).to eq('111130137368')
    end
  end
end
