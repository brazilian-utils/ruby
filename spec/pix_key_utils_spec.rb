require 'spec_helper'

RSpec.describe BrazilianUtils::PixKeyUtils do
  describe '.get_info' do
    it 'identifies a CPF' do
      expect(described_class.get_info('123.456.789-09')).to eq(type: 'cpf', value: '12345678909')
    end

    it 'identifies a CNPJ' do
      expect(described_class.get_info('00.038.166/0001-05')).to eq(type: 'cnpj', value: '00038166000105')
    end

    it 'identifies an email' do
      expect(described_class.get_info('fulano_da_silva.recebedor@example.com'))
        .to eq(type: 'email', value: 'fulano_da_silva.recebedor@example.com')
    end

    it 'identifies a phone' do
      expect(described_class.get_info('+5561912345678')).to eq(type: 'phone', value: '+5561912345678')
    end

    it 'identifies an EVP' do
      expect(described_class.get_info('71c7d9be-4b85-4e43-9f1c-1f3b8b4e9a2d'))
        .to eq(type: 'evp', value: '71c7d9be-4b85-4e43-9f1c-1f3b8b4e9a2d')
    end

    it 'returns nil for an invalid CPF' do
      expect(described_class.get_info('11257245286')).to be_nil
    end

    it 'returns nil for an empty string' do
      expect(described_class.get_info('')).to be_nil
    end
  end

  describe '.is_valid' do
    it 'validates a CPF' do
      expect(described_class.is_valid('123.456.789-09')).to be true
    end

    it 'validates a CNPJ' do
      expect(described_class.is_valid('00.038.166/0001-05')).to be true
    end

    it 'validates an email' do
      expect(described_class.is_valid('fulano_da_silva.recebedor@example.com')).to be true
    end

    it 'validates a phone' do
      expect(described_class.is_valid('+5561912345678')).to be true
    end

    it 'validates an EVP' do
      expect(described_class.is_valid('71c7d9be-4b85-4e43-9f1c-1f3b8b4e9a2d')).to be true
    end

    it 'rejects an invalid CPF' do
      expect(described_class.is_valid('11257245286')).to be false
    end

    it 'rejects an email without a TLD' do
      expect(described_class.is_valid('fulano@example')).to be false
    end

    it 'rejects a landline' do
      expect(described_class.is_valid('1130000000')).to be false
    end

    it 'rejects an empty string' do
      expect(described_class.is_valid('')).to be false
    end

    it 'restricts to the given types' do
      expect(described_class.is_valid('123.456.789-09', types: %w[cnpj])).to be false
      expect(described_class.is_valid('123.456.789-09', types: %w[cpf])).to be true
    end

    it 'rejects everything when given an empty type list' do
      expect(described_class.is_valid('123.456.789-09', types: [])).to be false
    end
  end
end
