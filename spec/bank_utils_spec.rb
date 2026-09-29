require 'spec_helper'

RSpec.describe BrazilianUtils::BankUtils do
  describe '.get_by_code' do
    it 'finds Banco do Brasil by its zero-padded code' do
      expect(described_class.get_by_code('001')).to eq(code: '001', ispb: '00000000', name: 'Banco do Brasil S.A.')
    end

    it 'accepts an unpadded code' do
      expect(described_class.get_by_code('1')).to eq(described_class.get_by_code('001'))
    end

    it 'accepts a numeric code' do
      expect(described_class.get_by_code(1)).to eq(described_class.get_by_code('001'))
    end

    it 'finds Itaú by code 341' do
      expect(described_class.get_by_code('341')).to eq(code: '341', ispb: '60701190', name: 'ITAÚ UNIBANCO S.A.')
    end

    it 'returns nil for a nonexistent code' do
      expect(described_class.get_by_code('999')).to be_nil
    end

    it 'returns nil for a non-numeric code' do
      expect(described_class.get_by_code('abc')).to be_nil
    end

    it 'returns nil for an empty string' do
      expect(described_class.get_by_code('')).to be_nil
    end
  end

  describe '.get_by_ispb' do
    it 'finds Banco do Brasil by ISPB' do
      expect(described_class.get_by_ispb('00000000')).to eq(code: '001', ispb: '00000000', name: 'Banco do Brasil S.A.')
    end

    it 'finds Itaú by ISPB' do
      expect(described_class.get_by_ispb('60701190')).to eq(code: '341', ispb: '60701190', name: 'ITAÚ UNIBANCO S.A.')
    end

    it 'returns nil for a nonexistent ISPB' do
      expect(described_class.get_by_ispb('99999999')).to be_nil
    end

    it 'returns nil for a non-numeric value' do
      expect(described_class.get_by_ispb('abc')).to be_nil
    end

    it 'returns nil for an empty string' do
      expect(described_class.get_by_ispb('')).to be_nil
    end
  end

  describe '.list' do
    it 'returns every bank with a COMPE code' do
      expect(described_class.list).to be_an(Array)
      expect(described_class.list.size).to eq(71)
    end

    it 'each entry has code, ispb and name' do
      described_class.list.each do |bank|
        expect(bank.keys).to contain_exactly(:code, :ispb, :name)
      end
    end
  end
end
