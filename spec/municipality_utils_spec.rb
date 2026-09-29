require 'spec_helper'

RSpec.describe BrazilianUtils::MunicipalityUtils do
  describe '.get_by_code' do
    it 'finds São Paulo' do
      expect(described_class.get_by_code('3550308')).to eq(code: '3550308', name: 'São Paulo', stateCode: 'SP')
    end

    it 'accepts a numeric code' do
      expect(described_class.get_by_code(3_550_308)).to eq(described_class.get_by_code('3550308'))
    end

    it 'finds a less common municipality' do
      expect(described_class.get_by_code('5101837')).to eq(
        code: '5101837', name: 'Boa Esperança do Norte', stateCode: 'MT'
      )
    end

    it 'accepts a masked code' do
      expect(described_class.get_by_code('355-030-8')).to eq(described_class.get_by_code('3550308'))
    end

    it 'returns nil for a code not in the table' do
      expect(described_class.get_by_code('0000000')).to be_nil
    end

    it 'returns nil for a too-short code' do
      expect(described_class.get_by_code('123')).to be_nil
    end

    it 'returns nil for a too-long code' do
      expect(described_class.get_by_code('12345678')).to be_nil
    end

    it 'returns nil for an empty string' do
      expect(described_class.get_by_code('')).to be_nil
    end
  end

  describe '.list' do
    it 'returns the single Distrito Federal municipality' do
      expect(described_class.list('DF')).to eq([{ code: '5300108', name: 'Brasília', stateCode: 'DF' }])
    end

    it 'returns an empty array for an unknown state' do
      expect(described_class.list('ZZ')).to eq([])
    end

    it 'is case-sensitive (lowercase state code returns empty)' do
      expect(described_class.list('df')).to eq([])
    end

    it 'returns every municipality when no state is given' do
      expect(described_class.list.size).to eq(5571)
    end
  end
end
