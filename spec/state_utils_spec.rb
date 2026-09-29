require 'spec_helper'

RSpec.describe BrazilianUtils::StateUtils do
  describe '.get_by_ibge_code' do
    it 'finds São Paulo by string code' do
      expect(described_class.get_by_ibge_code('35')).to eq(
        code: 'SP', name: 'São Paulo', regionCode: 'SE', regionName: 'Sudeste', ibgeCode: 35
      )
    end

    it 'finds São Paulo by numeric code' do
      expect(described_class.get_by_ibge_code(35)).to eq(described_class.get_by_ibge_code('35'))
    end

    it 'finds Distrito Federal' do
      expect(described_class.get_by_ibge_code('53')).to eq(
        code: 'DF', name: 'Distrito Federal', regionCode: 'CO', regionName: 'Centro-Oeste', ibgeCode: 53
      )
    end

    it 'returns nil for "00"' do
      expect(described_class.get_by_ibge_code('00')).to be_nil
    end

    it 'returns nil for "99"' do
      expect(described_class.get_by_ibge_code('99')).to be_nil
    end

    it 'returns nil for an empty string' do
      expect(described_class.get_by_ibge_code('')).to be_nil
    end
  end

  describe '.get_code_by_name' do
    it 'matches the exact accented name' do
      expect(described_class.get_code_by_name('São Paulo')).to eq('SP')
    end

    it 'ignores accents' do
      expect(described_class.get_code_by_name('Sao Paulo')).to eq('SP')
    end

    it 'ignores case' do
      expect(described_class.get_code_by_name('sao paulo')).to eq('SP')
    end

    it 'ignores surrounding whitespace' do
      expect(described_class.get_code_by_name('  São Paulo  ')).to eq('SP')
    end

    it 'matches "Rio Grande do Norte"' do
      expect(described_class.get_code_by_name('Rio Grande do Norte')).to eq('RN')
    end

    it 'matches "Distrito Federal"' do
      expect(described_class.get_code_by_name('Distrito Federal')).to eq('DF')
    end

    it 'returns nil for an unknown name' do
      expect(described_class.get_code_by_name('Neverland')).to be_nil
    end

    it 'returns nil for an empty string' do
      expect(described_class.get_code_by_name('')).to be_nil
    end
  end

  describe '.get_name_by_code' do
    it 'returns the name for "SP"' do
      expect(described_class.get_name_by_code('SP')).to eq('São Paulo')
    end

    it 'ignores case' do
      expect(described_class.get_name_by_code('sp')).to eq('São Paulo')
    end

    it 'ignores surrounding whitespace' do
      expect(described_class.get_name_by_code('  RJ  ')).to eq('Rio de Janeiro')
    end

    it 'returns the name for "DF"' do
      expect(described_class.get_name_by_code('DF')).to eq('Distrito Federal')
    end

    it 'returns nil for an unknown code' do
      expect(described_class.get_name_by_code('ZZ')).to be_nil
    end

    it 'returns nil for an empty string' do
      expect(described_class.get_name_by_code('')).to be_nil
    end
  end

  describe '.get_timezone' do
    it 'returns the SP timezone' do
      expect(described_class.get_timezone('SP')).to eq('America/Sao_Paulo')
    end

    it 'returns the AM timezone' do
      expect(described_class.get_timezone('AM')).to eq('America/Manaus')
    end

    it 'returns the AC timezone' do
      expect(described_class.get_timezone('AC')).to eq('America/Rio_Branco')
    end

    it 'returns the BA timezone' do
      expect(described_class.get_timezone('BA')).to eq('America/Bahia')
    end

    it 'ignores case' do
      expect(described_class.get_timezone('sp')).to eq('America/Sao_Paulo')
    end

    it 'ignores surrounding whitespace' do
      expect(described_class.get_timezone('  SP  ')).to eq('America/Sao_Paulo')
    end

    it 'returns nil for an unknown code' do
      expect(described_class.get_timezone('ZZ')).to be_nil
    end

    it 'returns nil for an empty string' do
      expect(described_class.get_timezone('')).to be_nil
    end
  end

  describe '.list' do
    it 'returns all 27 states sorted by name' do
      expect(described_class.list).to eq(
        [
          { code: 'AC', name: 'Acre', regionCode: 'N', regionName: 'Norte', ibgeCode: 12 },
          { code: 'AL', name: 'Alagoas', regionCode: 'NE', regionName: 'Nordeste', ibgeCode: 27 },
          { code: 'AP', name: 'Amapá', regionCode: 'N', regionName: 'Norte', ibgeCode: 16 },
          { code: 'AM', name: 'Amazonas', regionCode: 'N', regionName: 'Norte', ibgeCode: 13 },
          { code: 'BA', name: 'Bahia', regionCode: 'NE', regionName: 'Nordeste', ibgeCode: 29 },
          { code: 'CE', name: 'Ceará', regionCode: 'NE', regionName: 'Nordeste', ibgeCode: 23 },
          { code: 'DF', name: 'Distrito Federal', regionCode: 'CO', regionName: 'Centro-Oeste', ibgeCode: 53 },
          { code: 'ES', name: 'Espírito Santo', regionCode: 'SE', regionName: 'Sudeste', ibgeCode: 32 },
          { code: 'GO', name: 'Goiás', regionCode: 'CO', regionName: 'Centro-Oeste', ibgeCode: 52 },
          { code: 'MA', name: 'Maranhão', regionCode: 'NE', regionName: 'Nordeste', ibgeCode: 21 },
          { code: 'MT', name: 'Mato Grosso', regionCode: 'CO', regionName: 'Centro-Oeste', ibgeCode: 51 },
          { code: 'MS', name: 'Mato Grosso do Sul', regionCode: 'CO', regionName: 'Centro-Oeste', ibgeCode: 50 },
          { code: 'MG', name: 'Minas Gerais', regionCode: 'SE', regionName: 'Sudeste', ibgeCode: 31 },
          { code: 'PA', name: 'Pará', regionCode: 'N', regionName: 'Norte', ibgeCode: 15 },
          { code: 'PB', name: 'Paraíba', regionCode: 'NE', regionName: 'Nordeste', ibgeCode: 25 },
          { code: 'PR', name: 'Paraná', regionCode: 'S', regionName: 'Sul', ibgeCode: 41 },
          { code: 'PE', name: 'Pernambuco', regionCode: 'NE', regionName: 'Nordeste', ibgeCode: 26 },
          { code: 'PI', name: 'Piauí', regionCode: 'NE', regionName: 'Nordeste', ibgeCode: 22 },
          { code: 'RJ', name: 'Rio de Janeiro', regionCode: 'SE', regionName: 'Sudeste', ibgeCode: 33 },
          { code: 'RN', name: 'Rio Grande do Norte', regionCode: 'NE', regionName: 'Nordeste', ibgeCode: 24 },
          { code: 'RS', name: 'Rio Grande do Sul', regionCode: 'S', regionName: 'Sul', ibgeCode: 43 },
          { code: 'RO', name: 'Rondônia', regionCode: 'N', regionName: 'Norte', ibgeCode: 11 },
          { code: 'RR', name: 'Roraima', regionCode: 'N', regionName: 'Norte', ibgeCode: 14 },
          { code: 'SC', name: 'Santa Catarina', regionCode: 'S', regionName: 'Sul', ibgeCode: 42 },
          { code: 'SP', name: 'São Paulo', regionCode: 'SE', regionName: 'Sudeste', ibgeCode: 35 },
          { code: 'SE', name: 'Sergipe', regionCode: 'NE', regionName: 'Nordeste', ibgeCode: 28 },
          { code: 'TO', name: 'Tocantins', regionCode: 'N', regionName: 'Norte', ibgeCode: 17 }
        ]
      )
    end
  end
end
