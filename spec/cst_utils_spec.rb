require 'spec_helper'

RSpec.describe BrazilianUtils::CSTUtils do
  describe '.is_valid' do
    it 'validates a 3-digit ICMS code' do
      expect(described_class.is_valid('110')).to be true
    end

    it 'validates an IPI code' do
      expect(described_class.is_valid('00')).to be true
    end

    it 'validates a PIS/COFINS code' do
      expect(described_class.is_valid('07')).to be true
    end

    it 'rejects a nonexistent code' do
      expect(described_class.is_valid('999')).to be false
    end

    it 'rejects a value with a malformed separator' do
      expect(described_class.is_valid('0-0')).to be false
    end

    it 'accepts the ICMS form with a separator after the origin digit' do
      expect(described_class.is_valid('1-10')).to be true
    end

    it 'pads a single digit to the 3-digit ICMS form' do
      expect(described_class.is_valid('0')).to be true # "000": origin 0, Tabela B "00"
    end

    context 'with the tax option' do
      it 'restricts to icms' do
        expect(described_class.is_valid('110', tax: 'icms')).to be true
        expect(described_class.is_valid('00', tax: 'icms')).to be false
      end

      it 'restricts to ipi' do
        expect(described_class.is_valid('00', tax: 'ipi')).to be true
        expect(described_class.is_valid('07', tax: 'ipi')).to be false
      end

      it 'restricts to pis/cofins' do
        expect(described_class.is_valid('07', tax: 'pis')).to be true
        expect(described_class.is_valid('07', tax: 'cofins')).to be true
      end
    end
  end
end
