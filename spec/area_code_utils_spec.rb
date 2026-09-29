require 'spec_helper'

RSpec.describe BrazilianUtils::AreaCodeUtils do
  describe '.get_info' do
    it 'returns info for DDD 11 (São Paulo)' do
      expect(described_class.get_info('11')).to eq(
        areaCode: 11, stateCode: 'SP', stateName: 'São Paulo',
        regionCode: 'SE', regionName: 'Sudeste', stateCodes: ['SP']
      )
    end

    it 'accepts a numeric area code' do
      expect(described_class.get_info(11)).to eq(described_class.get_info('11'))
    end

    it 'lists both states for DDD 61 (Distrito Federal / Goiás)' do
      expect(described_class.get_info('61')).to eq(
        areaCode: 61, stateCode: 'DF', stateName: 'Distrito Federal',
        regionCode: 'CO', regionName: 'Centro-Oeste', stateCodes: %w[DF GO]
      )
    end

    it 'lists both states for DDD 42 (Paraná / Santa Catarina)' do
      expect(described_class.get_info(42)).to eq(
        areaCode: 42, stateCode: 'PR', stateName: 'Paraná',
        regionCode: 'S', regionName: 'Sul', stateCodes: %w[PR SC]
      )
    end

    it 'returns nil for "00"' do
      expect(described_class.get_info('00')).to be_nil
    end

    it 'returns nil for an unassigned DDD' do
      expect(described_class.get_info('20')).to be_nil
    end

    it 'returns nil for an empty string' do
      expect(described_class.get_info('')).to be_nil
    end
  end

  describe '.list_by_state' do
    it 'lists all São Paulo DDDs' do
      expect(described_class.list_by_state('SP')).to eq([11, 12, 13, 14, 15, 16, 17, 18, 19])
    end

    it 'is case-insensitive' do
      expect(described_class.list_by_state('sp')).to eq([11, 12, 13, 14, 15, 16, 17, 18, 19])
    end

    it 'lists the single Acre DDD' do
      expect(described_class.list_by_state('AC')).to eq([68])
    end

    it 'lists the Pernambuco DDDs' do
      expect(described_class.list_by_state('PE')).to eq([81, 87])
    end

    it 'includes shared DDDs for Santa Catarina' do
      expect(described_class.list_by_state('SC')).to eq([42, 47, 48, 49])
    end

    it 'returns an empty array for a non-state code' do
      expect(described_class.list_by_state('XX')).to eq([])
    end

    it 'returns an empty array for an empty string' do
      expect(described_class.list_by_state('')).to eq([])
    end
  end
end
