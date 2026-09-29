require 'spec_helper'

RSpec.describe BrazilianUtils::CBOUtils do
  describe '.is_valid' do
    it 'validates "212405"' do
      expect(described_class.is_valid('212405')).to be true
    end

    it 'accepts the masked form' do
      expect(described_class.is_valid('2124-05')).to be true
    end

    it 'validates a code with a leading zero' do
      expect(described_class.is_valid('010205')).to be true
    end

    it 'rejects a nonexistent code' do
      expect(described_class.is_valid('223150')).to be false
    end

    it 'rejects all zeros' do
      expect(described_class.is_valid('000000')).to be false
    end

    it 'rejects a too-short value' do
      expect(described_class.is_valid('21240')).to be false
    end

    it 'rejects letters' do
      expect(described_class.is_valid('abcdef')).to be false
    end

    it 'rejects an empty string' do
      expect(described_class.is_valid('')).to be false
    end
  end

  describe '.get' do
    it 'returns code and title' do
      expect(described_class.get('212405')).to eq(code: '212405', description: 'Analista de desenvolvimento de sistemas')
    end

    it 'accepts the masked form' do
      expect(described_class.get('2124-05')).to eq(described_class.get('212405'))
    end

    it 'pads a leading-zero code' do
      expect(described_class.get('0102-05')).to eq(code: '010205', description: 'Oficial da aeronáutica')
    end

    it 'returns nil for a nonexistent code' do
      expect(described_class.get('223150')).to be_nil
    end

    it 'returns nil for all zeros' do
      expect(described_class.get('000000')).to be_nil
    end

    it 'returns nil for an empty string' do
      expect(described_class.get('')).to be_nil
    end
  end

  describe '.parse' do
    it 'removes the mask' do
      expect(described_class.parse('2124-05')).to eq('212405')
    end

    it 'strips non-digit characters' do
      expect(described_class.parse('21?ABC24-05abc')).to eq('212405')
    end

    it 'returns an empty string for empty input' do
      expect(described_class.parse('')).to eq('')
    end

    it 'caps the result to 6 characters' do
      expect(described_class.parse('212405999')).to eq('212405')
    end
  end
end
