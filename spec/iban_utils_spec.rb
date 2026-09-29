require 'spec_helper'

RSpec.describe BrazilianUtils::IBANUtils do
  describe '.format' do
    it 'groups a 29-char IBAN into blocks of 4' do
      expect(described_class.format('BR1500000000000010932840814P2'))
        .to eq('BR15 0000 0000 0000 1093 2840 814P 2')
    end

    it 'upper-cases a lowercase IBAN' do
      expect(described_class.format('br1500000000000010932840814p2'))
        .to eq('BR15 0000 0000 0000 1093 2840 814P 2')
    end

    it 'masks a partial value as far as it goes' do
      expect(described_class.format('BR150')).to eq('BR15 0')
    end

    it 'returns an empty string for empty input' do
      expect(described_class.format('')).to eq('')
    end
  end

  describe '.is_valid' do
    it 'validates a Brazilian IBAN' do
      expect(described_class.is_valid('BR1500000000000010932840814P2')).to be true
    end

    it 'accepts the masked form' do
      expect(described_class.is_valid('BR15 0000 0000 0000 1093 2840 814P 2')).to be true
    end

    it 'is case-insensitive' do
      expect(described_class.is_valid('br1500000000000010932840814p2')).to be true
    end

    it 'rejects a wrong check digit' do
      expect(described_class.is_valid('BR1500000000000010932840814P3')).to be false
    end

    it 'rejects a non-Brazilian IBAN' do
      expect(described_class.is_valid('DE89370400440532013000')).to be false
    end

    it 'rejects a too-short value' do
      expect(described_class.is_valid('BR15000000000000109328408')).to be false
    end

    it 'rejects an empty string' do
      expect(described_class.is_valid('')).to be false
    end
  end

  describe '.get_info' do
    it 'parses a Brazilian IBAN' do
      expect(described_class.get_info('BR1500000000000010932840814P2')).to eq(
        countryCode: 'BR', checkDigits: '15', bankIspb: '00000000',
        branch: '00001', account: '0932840814', accountType: 'P', owner: '2'
      )
    end

    it 'accepts the masked form' do
      expect(described_class.get_info('BR15 0000 0000 0000 1093 2840 814P 2'))
        .to eq(described_class.get_info('BR1500000000000010932840814P2'))
    end

    it 'parses another Brazilian IBAN' do
      expect(described_class.get_info('BR3860701190000010000012345C1')).to eq(
        countryCode: 'BR', checkDigits: '38', bankIspb: '60701190',
        branch: '00001', account: '0000012345', accountType: 'C', owner: '1'
      )
    end

    it 'returns nil for a wrong check digit' do
      expect(described_class.get_info('BR1500000000000010932840814P3')).to be_nil
    end

    it 'returns nil for a non-Brazilian IBAN' do
      expect(described_class.get_info('DE89370400440532013000')).to be_nil
    end

    it 'returns nil for an empty string' do
      expect(described_class.get_info('')).to be_nil
    end
  end

  describe '.parse' do
    it 'removes the mask' do
      expect(described_class.parse('BR15 0000 0000 0000 1093 2840 814P 2'))
        .to eq('BR1500000000000010932840814P2')
    end

    it 'strips mixed lowercase separators' do
      expect(described_class.parse('br15-0000.0000/0000 1093 2840 814p-2'))
        .to eq('BR1500000000000010932840814P2')
    end

    it 'caps the result to 29 characters' do
      expect(described_class.parse('BR1500000000000010932840814P2EXTRA'))
        .to eq('BR1500000000000010932840814P2')
    end

    it 'returns an empty string for empty input' do
      expect(described_class.parse('')).to eq('')
    end
  end
end
