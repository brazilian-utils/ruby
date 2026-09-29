require 'spec_helper'

RSpec.describe BrazilianUtils::CNAEUtils do
  describe '.format' do
    it 'masks a 7-digit code' do
      expect(described_class.format('6201501')).to eq('6201-5/01')
    end

    it 'is idempotent on an already-formatted code' do
      expect(described_class.format('6201-5/01')).to eq('6201-5/01')
    end

    it 'masks a partial code as far as it goes' do
      expect(described_class.format('62015')).to eq('6201-5')
    end

    it 'returns an empty string for empty input' do
      expect(described_class.format('')).to eq('')
    end
  end

  describe '.is_valid' do
    it 'validates "6201501"' do
      expect(described_class.is_valid('6201501')).to be true
    end

    it 'accepts the masked form' do
      expect(described_class.is_valid('6201-5/01')).to be true
    end

    it 'validates a code with a leading zero' do
      expect(described_class.is_valid('0111301')).to be true
    end

    it 'rejects all zeros' do
      expect(described_class.is_valid('0000000')).to be false
    end

    it 'rejects a too-short value' do
      expect(described_class.is_valid('620150')).to be false
    end

    it 'rejects a too-long value' do
      expect(described_class.is_valid('62015011')).to be false
    end

    it 'rejects letters' do
      expect(described_class.is_valid('abcdefg')).to be false
    end

    it 'rejects an empty string' do
      expect(described_class.is_valid('')).to be false
    end
  end

  describe '.get' do
    it 'returns code and description' do
      expect(described_class.get('6201501')).to eq(
        code: '6201501', description: 'DESENVOLVIMENTO DE PROGRAMAS DE COMPUTADOR SOB ENCOMENDA'
      )
    end

    it 'accepts the masked form' do
      expect(described_class.get('6201-5/01')).to eq(described_class.get('6201501'))
    end

    it 'finds a leading-zero code' do
      expect(described_class.get('0111-3/01')).to eq(code: '0111301', description: 'CULTIVO DE ARROZ')
    end

    it 'returns nil for all zeros' do
      expect(described_class.get('0000000')).to be_nil
    end

    it 'returns nil for a too-short value' do
      expect(described_class.get('620150')).to be_nil
    end

    it 'returns nil for an empty string' do
      expect(described_class.get('')).to be_nil
    end
  end

  describe '.parse' do
    it 'removes the mask' do
      expect(described_class.parse('6201-5/01')).to eq('6201501')
    end

    it 'strips non-digit characters' do
      expect(described_class.parse('62?ABC01-5/01abc')).to eq('6201501')
    end

    it 'returns an empty string for empty input' do
      expect(described_class.parse('')).to eq('')
    end

    it 'caps the result to 7 characters' do
      expect(described_class.parse('6201501999')).to eq('6201501')
    end
  end
end
