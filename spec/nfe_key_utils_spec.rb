require 'spec_helper'

RSpec.describe BrazilianUtils::NfeKeyUtils do
  KEY = '35170458716523000119550010000000121000123458'.freeze

  describe '.format' do
    it 'groups a 44-digit key' do
      expect(described_class.format(KEY))
        .to eq('3517 0458 7165 2300 0119 5500 1000 0000 1210 0012 3458')
    end

    it 'strips the NFe Id prefix' do
      expect(described_class.format("NFe#{KEY}"))
        .to eq('3517 0458 7165 2300 0119 5500 1000 0000 1210 0012 3458')
    end

    it 'masks a partial value as far as it goes' do
      expect(described_class.format('12345')).to eq('1234 5')
    end

    it 'returns an empty string for empty input' do
      expect(described_class.format('')).to eq('')
    end
  end

  describe '.is_valid' do
    it 'validates a well-formed key' do
      expect(described_class.is_valid(KEY)).to be true
    end

    it 'accepts the masked form' do
      expect(described_class.is_valid('3517 0458 7165 2300 0119 5500 1000 0000 1210 0012 3458')).to be true
    end

    it 'strips the NFe Id prefix' do
      expect(described_class.is_valid("NFe#{KEY}")).to be true
    end

    it 'rejects a wrong check digit / structure' do
      expect(described_class.is_valid('35170458716523000119550010000000001000123457')).to be false
    end

    it 'rejects a too-short value' do
      expect(described_class.is_valid('3517045871652300011955001000000012100012345')).to be false
    end

    it 'rejects an empty string' do
      expect(described_class.is_valid('')).to be false
    end
  end

  describe '.get_info' do
    it 'parses a well-formed key' do
      expect(described_class.get_info(KEY)).to eq(
        stateCode: 'SP', year: 2017, month: 4, taxId: '58716523000119',
        model: '55', series: 1, number: 12, emissionType: 1,
        code: '00012345', checkDigit: 8
      )
    end

    it 'returns nil for a wrong check digit' do
      expect(described_class.get_info('35170458716523000119550010000000121000123459')).to be_nil
    end

    it 'returns nil for an empty string' do
      expect(described_class.get_info('')).to be_nil
    end
  end

  describe '.parse' do
    it 'removes the mask' do
      expect(described_class.parse('3517 0458 7165 2300 0119 5500 1000 0000 1210 0012 3458')).to eq(KEY)
    end

    it 'strips the NFe Id prefix' do
      expect(described_class.parse("NFe#{KEY}")).to eq(KEY)
    end

    it 'keeps a partial value as far as it goes' do
      expect(described_class.parse('3517 0458')).to eq('35170458')
    end

    it 'returns an empty string for empty input' do
      expect(described_class.parse('')).to eq('')
    end
  end
end
