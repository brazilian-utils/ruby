require 'spec_helper'

RSpec.describe BrazilianUtils::RegistroProfissionalUtils do
  # NOTE: no acceptance cases were available in the contract for this
  # function; these specs cover the literal example patterns from its
  # description only, and have not been cross-checked against a reference
  # implementation.

  describe '.is_valid' do
    it 'validates an OAB number' do
      expect(described_class.is_valid(value: '123456/SP', council: 'OAB')).to be true
    end

    it 'validates a CRM number with a hyphen' do
      expect(described_class.is_valid(value: '123456-SP', council: 'CRM')).to be true
    end

    it 'validates a CRO number' do
      expect(described_class.is_valid(value: '123/SP', council: 'CRO')).to be true
    end

    it 'validates a CRP number' do
      expect(described_class.is_valid(value: '06/12345', council: 'CRP')).to be true
    end

    it 'rejects an out-of-range CRP region' do
      expect(described_class.is_valid(value: '25/12345', council: 'CRP')).to be false
    end

    it 'validates a CRC number' do
      expect(described_class.is_valid(value: 'SP-123456/O-3', council: 'CRC')).to be true
    end

    it 'validates a CRC number with a transfer suffix' do
      expect(described_class.is_valid(value: 'SP-123456/O-3 T-MG', council: 'CRC')).to be true
    end

    it 'checks the expected state when given' do
      expect(described_class.is_valid(value: '123456/SP', council: 'OAB', state: 'RJ')).to be false
      expect(described_class.is_valid(value: '123456/SP', council: 'OAB', state: 'SP')).to be true
    end

    it 'rejects an unknown council' do
      expect(described_class.is_valid(value: '123456/SP', council: 'CREA')).to be false
    end

    it 'rejects a non-Hash argument' do
      expect(described_class.is_valid('123456/SP')).to be false
    end
  end
end
