require 'spec_helper'

RSpec.describe BrazilianUtils::CFOPUtils do
  describe '.is_valid' do
    it 'validates "5102"' do
      expect(described_class.is_valid('5102')).to be true
    end

    it 'accepts the masked form' do
      expect(described_class.is_valid('5.102')).to be true
    end

    it 'validates "7504"' do
      expect(described_class.is_valid('7504')).to be true
    end

    it 'rejects "0000"' do
      expect(described_class.is_valid('0000')).to be false
    end

    it 'rejects a group heading' do
      expect(described_class.is_valid('1100')).to be false
    end

    it 'rejects a too-short value' do
      expect(described_class.is_valid('510')).to be false
    end

    it 'rejects letters' do
      expect(described_class.is_valid('abcd')).to be false
    end

    it 'rejects an empty string' do
      expect(described_class.is_valid('')).to be false
    end
  end

  describe '.get' do
    it 'returns code and description' do
      result = described_class.get('5102')
      expect(result[:code]).to eq('5102')
      expect(result[:description]).to include('Venda de mercadoria')
    end

    it 'accepts the masked form' do
      expect(described_class.get('5.102')).to eq(described_class.get('5102'))
    end

    it 'returns nil for a group heading' do
      expect(described_class.get('1100')).to be_nil
    end

    it 'returns nil for a too-short value' do
      expect(described_class.get('510')).to be_nil
    end

    it 'returns nil for an empty string' do
      expect(described_class.get('')).to be_nil
    end
  end

  describe '.parse' do
    it 'removes the mask' do
      expect(described_class.parse('5.102')).to eq('5102')
    end

    it 'keeps an unmasked value unchanged' do
      expect(described_class.parse('5102')).to eq('5102')
    end

    it 'strips non-digit characters' do
      expect(described_class.parse('5?ABC.102abc')).to eq('5102')
    end

    it 'returns an empty string for empty input' do
      expect(described_class.parse('')).to eq('')
    end

    it 'caps the result to 4 characters' do
      expect(described_class.parse('5102999')).to eq('5102')
    end
  end
end
