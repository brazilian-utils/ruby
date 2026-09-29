require 'spec_helper'

RSpec.describe BrazilianUtils::LegalNatureUtils do
  # These fixtures follow the CONCLA "Natureza Jurídica 2021" table (92 codes
  # in force + a best-effort list of codes retired by past revisions), which
  # differs in a few entries/descriptions from the older DREI table this
  # module used to ship (e.g. "2208"/"3123"/"5002" moved or were retired).

  describe '.is_valid' do
    context 'with valid legal nature codes (without hyphen)' do
      it 'validates "2240" (Sociedade Simples Limitada)' do
        expect(described_class.is_valid('2240')).to be true
      end

      it 'validates "1015" (Órgão Público Federal)' do
        expect(described_class.is_valid('1015')).to be true
      end

      it 'validates "2062" (Sociedade Empresária Limitada)' do
        expect(described_class.is_valid('2062')).to be true
      end

      it 'validates "4014" (Empresa Individual Imobiliária)' do
        expect(described_class.is_valid('4014')).to be true
      end

      it 'validates "5010" (Organização Internacional)' do
        expect(described_class.is_valid('5010')).to be true
      end
    end

    context 'with a retired code' do
      it 'still validates "2208" (retired, folded into 2275)' do
        expect(described_class.is_valid('2208')).to be true
      end

      it 'still validates "3123" (retired Partido Político)' do
        expect(described_class.is_valid('3123')).to be true
      end
    end

    context 'with valid codes (with hyphen format)' do
      it 'validates "224-0" (with hyphen)' do
        expect(described_class.is_valid('224-0')).to be true
      end
    end

    context 'contract cases' do
      it 'rejects "3329" (not in table)' do
        expect(described_class.is_valid('3329')).to be false
      end

      it 'rejects "0000" (not in table)' do
        expect(described_class.is_valid('0000')).to be false
      end

      it 'validates "2240"' do
        expect(described_class.is_valid('2240')).to be true
      end

      it 'rejects "2241" (not in table)' do
        expect(described_class.is_valid('2241')).to be false
      end

      it 'rejects "3311" (not in table)' do
        expect(described_class.is_valid('3311')).to be false
      end

      it 'validates "224-0"' do
        expect(described_class.is_valid('224-0')).to be true
      end

      it 'rejects empty string' do
        expect(described_class.is_valid('')).to be false
      end

      it 'rejects a string with spaces only' do
        expect(described_class.is_valid('   ')).to be false
      end

      it 'rejects "abc"' do
        expect(described_class.is_valid('abc')).to be false
      end
    end

    context 'with invalid formats' do
      it 'rejects code with wrong length "123"' do
        expect(described_class.is_valid('123')).to be false
      end

      it 'rejects code with wrong length "12345"' do
        expect(described_class.is_valid('12345')).to be false
      end

      it 'rejects code with letters "abcd"' do
        expect(described_class.is_valid('abcd')).to be false
      end
    end

    context 'with non-string inputs' do
      it 'rejects nil' do
        expect(described_class.is_valid(nil)).to be false
      end

      it 'rejects an array' do
        expect(described_class.is_valid(['2062'])).to be false
      end

      it 'rejects a hash' do
        expect(described_class.is_valid({ code: '2062' })).to be false
      end
    end

    context 'with whitespace/hyphen/dot variations' do
      it 'validates code with leading spaces' do
        expect(described_class.is_valid('  2062')).to be true
      end

      it 'validates code with a dot separator' do
        expect(described_class.is_valid('20.62')).to be true
      end
    end
  end

  describe '.valid?' do
    it 'is an alias for is_valid' do
      expect(described_class.method(:valid?)).to eq(described_class.method(:is_valid))
    end
  end

  describe '.get_description' do
    it 'returns description for "2240"' do
      expect(described_class.get_description('2240')).to eq('Sociedade Simples Limitada')
    end

    it 'returns description for "224-0"' do
      expect(described_class.get_description('224-0')).to eq('Sociedade Simples Limitada')
    end

    it 'returns nil for "0000"' do
      expect(described_class.get_description('0000')).to be_nil
    end

    it 'returns nil for invalid format' do
      expect(described_class.get_description('invalid')).to be_nil
    end

    it 'returns nil for nil input' do
      expect(described_class.get_description(nil)).to be_nil
    end
  end

  describe '.get' do
    it 'returns the full entry for an in-force code' do
      expect(described_class.get('2062')).to eq(
        code: '2062',
        description: 'Sociedade Empresária Limitada',
        category: { code: '2', description: 'Entidades Empresariais' },
        legacy: false
      )
    end

    it 'accepts the masked form' do
      expect(described_class.get('206-2')).to eq(described_class.get('2062'))
    end

    it 'flags a retired code as legacy, with its successor code' do
      entry = described_class.get('2208')
      expect(entry[:legacy]).to be true
      expect(entry[:currentCode]).to eq('2275')
    end

    it 'returns nil for an unknown code' do
      expect(described_class.get('0000')).to be_nil
    end

    it 'returns nil for a code that is too short' do
      expect(described_class.get('206')).to be_nil
    end

    it 'returns nil for an empty string' do
      expect(described_class.get('')).to be_nil
    end
  end

  describe '.format' do
    it 'masks a 4-digit code' do
      expect(described_class.format('2062')).to eq('206-2')
    end

    it 'is idempotent on an already-formatted code' do
      expect(described_class.format('206-2')).to eq('206-2')
    end

    it 'returns a partial value unmasked' do
      expect(described_class.format('206')).to eq('206')
    end

    it 'returns an empty string for empty input' do
      expect(described_class.format('')).to eq('')
    end

    it 'left-pads with zeros first when options[:pad] is set' do
      expect(described_class.format('62', pad: true)).to eq('006-2')
    end
  end

  describe '.generate' do
    it 'generates a code that passes is_valid' do
      10.times do
        code = described_class.generate
        expect(described_class.is_valid(code)).to be true
      end
    end

    it 'never generates a retired code' do
      100.times do
        code = described_class.generate
        expect(described_class.get(code)[:legacy]).to be false
      end
    end
  end

  describe '.list' do
    it 'returns a hash' do
      expect(described_class.list).to be_a(Hash)
    end

    it 'returns exactly the 92 in-force codes by default' do
      expect(described_class.list.size).to eq(92)
    end

    it 'matches the CONCLA in-force table' do
      all_codes = described_class.list
      expect(all_codes['2062']).to eq('Sociedade Empresária Limitada')
      expect(all_codes['1015']).to eq('Órgão Público do Poder Executivo Federal')
      expect(all_codes['5010']).to eq('Organização Internacional')
    end

    it 'does not include a retired code by default' do
      expect(described_class.list).not_to include('2208')
    end

    it 'includes retired codes when asked' do
      with_retired = described_class.list(include_retired: true)
      expect(with_retired.size).to eq(98)
      expect(with_retired['2208']).to eq('Entidade Binacional Itaipu')
    end

    it 'returns a copy (not the original)' do
      codes1 = described_class.list
      codes2 = described_class.list
      expect(codes1).not_to be(codes2)
    end

    it 'has a .list_all alias' do
      expect(described_class.list_all).to eq(described_class.list)
    end
  end

  describe '.list_by_category' do
    it 'returns category 5 exactly' do
      category5 = described_class.list_by_category('5')
      expect(category5.map { |e| e[:code] }).to eq(%w[5010 5029 5037])
      expect(category5.first[:description]).to eq('Organização Internacional')
    end

    it 'accepts category as a number' do
      expect(described_class.list_by_category(5)).to eq(described_class.list_by_category('5'))
    end

    it 'returns category 4 exactly' do
      category4 = described_class.list_by_category('4')
      expect(category4.map { |e| e[:code] }).to eq(%w[4014 4022 4081 4090 4111 4120])
    end

    it 'returns an empty array for category "0"' do
      expect(described_class.list_by_category('0')).to eq([])
    end

    it 'returns an empty array for category "9"' do
      expect(described_class.list_by_category('9')).to eq([])
    end

    it 'returns an empty array when given a full code instead of a category' do
      expect(described_class.list_by_category('2062')).to eq([])
    end

    it 'returns an empty array for an empty string' do
      expect(described_class.list_by_category('')).to eq([])
    end

    it 'each entry validates against is_valid' do
      described_class.list_by_category('2').each do |entry|
        expect(described_class.is_valid(entry[:code])).to be true
      end
    end
  end

  describe '.get_category' do
    it 'returns 1 for category 1 codes' do
      expect(described_class.get_category('1015')).to eq(1)
    end

    it 'returns 2 for category 2 codes' do
      expect(described_class.get_category('2062')).to eq(2)
    end

    it 'returns category for the hyphenated form' do
      expect(described_class.get_category('206-2')).to eq(2)
    end

    it 'returns nil for a non-existent code' do
      expect(described_class.get_category('9999')).to be_nil
    end

    it 'returns nil for nil input' do
      expect(described_class.get_category(nil)).to be_nil
    end
  end

  describe '.parse' do
    it 'removes the hyphen mask' do
      expect(described_class.parse('206-2')).to eq('2062')
    end

    it 'keeps an already-clean value unchanged' do
      expect(described_class.parse('2062')).to eq('2062')
    end

    it 'caps the result to 4 characters' do
      expect(described_class.parse('206299')).to eq('2062')
    end

    it 'returns an empty string for empty input' do
      expect(described_class.parse('')).to eq('')
    end
  end

  describe 'integration tests' do
    it 'validates and retrieves description for the same code' do
      code = '2062'
      expect(described_class.is_valid(code)).to be true
      expect(described_class.get_description(code)).to eq('Sociedade Empresária Limitada')
    end

    it 'all codes in list are valid' do
      described_class.list.each_key do |code|
        expect(described_class.is_valid(code)).to be true
      end
    end
  end
end
