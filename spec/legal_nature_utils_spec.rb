require 'spec_helper'

RSpec.describe BrazilianUtils::LegalNatureUtils do
  describe '.is_valid' do
    context 'with valid legal nature codes (without hyphen)' do
      it 'validates "2062" (Sociedade Empresária Limitada)' do
        expect(described_class.is_valid('2062')).to be true
      end

      it 'validates "1015" (Órgão Público Federal)' do
        expect(described_class.is_valid('1015')).to be true
      end

      it 'validates "2305" (Empresa Individual de Responsabilidade Limitada)' do
        expect(described_class.is_valid('2305')).to be true
      end

      it 'validates "3123" (Partido Político)' do
        expect(described_class.is_valid('3123')).to be true
      end

      it 'validates "4014" (Empresa Individual Imobiliária)' do
        expect(described_class.is_valid('4014')).to be true
      end

      it 'validates "5002" (Organização Internacional)' do
        expect(described_class.is_valid('5002')).to be true
      end

      it 'validates "2046" (Sociedade Anônima Aberta)' do
        expect(described_class.is_valid('2046')).to be true
      end

      it 'validates "2054" (Sociedade Anônima Fechada)' do
        expect(described_class.is_valid('2054')).to be true
      end

      it 'validates "2143" (Cooperativa)' do
        expect(described_class.is_valid('2143')).to be true
      end

      it 'validates "3042" (Organização Social)' do
        expect(described_class.is_valid('3042')).to be true
      end
    end

    context 'with valid codes (with hyphen format)' do
      it 'validates "206-2" (with hyphen)' do
        expect(described_class.is_valid('206-2')).to be true
      end

      it 'validates "101-5" (with hyphen)' do
        expect(described_class.is_valid('101-5')).to be true
      end

      it 'validates "230-5" (with hyphen)' do
        expect(described_class.is_valid('230-5')).to be true
      end

      it 'validates "312-3" (with hyphen)' do
        expect(described_class.is_valid('312-3')).to be true
      end

      it 'validates "500-2" (with hyphen)' do
        expect(described_class.is_valid('500-2')).to be true
      end
    end

    context 'with codes from all categories' do
      it 'validates category 1 code (Administração Pública)' do
        expect(described_class.is_valid('1104')).to be true  # Autarquia Federal
      end

      it 'validates category 2 code (Entidades Empresariais)' do
        expect(described_class.is_valid('2011')).to be true  # Empresa Pública
      end

      it 'validates category 3 code (Entidades Sem Fins Lucrativos)' do
        expect(described_class.is_valid('3050')).to be true  # Oscip
      end

      it 'validates category 4 code (Pessoas Físicas)' do
        expect(described_class.is_valid('4022')).to be true  # Segurado Especial
      end

      it 'validates category 5 code (Organizações Internacionais)' do
        expect(described_class.is_valid('5002')).to be true
      end
    end

    context 'with invalid legal nature codes' do
      it 'rejects "9999" (not in table)' do
        expect(described_class.is_valid('9999')).to be false
      end

      it 'rejects "0000" (not in table)' do
        expect(described_class.is_valid('0000')).to be false
      end

      it 'rejects "1234" (not in table)' do
        expect(described_class.is_valid('1234')).to be false
      end

      it 'rejects "6000" (invalid category)' do
        expect(described_class.is_valid('6000')).to be false
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

      it 'rejects code with mixed alphanumeric "12ab"' do
        expect(described_class.is_valid('12ab')).to be false
      end

      it 'rejects empty string' do
        expect(described_class.is_valid('')).to be false
      end

      it 'rejects string with spaces only' do
        expect(described_class.is_valid('    ')).to be false
      end

      it 'rejects code with spaces in the middle' do
        expect(described_class.is_valid('20 62')).to be false
      end
    end

    context 'with non-string inputs' do
      it 'rejects nil' do
        expect(described_class.is_valid(nil)).to be false
      end

      it 'rejects integer' do
        expect(described_class.is_valid(2062)).to be false
      end

      it 'rejects float' do
        expect(described_class.is_valid(20.62)).to be false
      end

      it 'rejects array' do
        expect(described_class.is_valid(['2062'])).to be false
      end

      it 'rejects hash' do
        expect(described_class.is_valid({ code: '2062' })).to be false
      end
    end

    context 'with whitespace variations' do
      it 'validates code with leading spaces' do
        expect(described_class.is_valid('  2062')).to be true
      end

      it 'validates code with trailing spaces' do
        expect(described_class.is_valid('2062  ')).to be true
      end

      it 'validates code with surrounding spaces' do
        expect(described_class.is_valid('  2062  ')).to be true
      end
    end
  end

  describe '.valid?' do
    it 'is an alias for is_valid' do
      expect(described_class.method(:valid?)).to eq(described_class.method(:is_valid))
    end

    it 'works the same as is_valid with valid code' do
      expect(described_class.valid?('2062')).to be true
    end

    it 'works the same as is_valid with invalid code' do
      expect(described_class.valid?('9999')).to be false
    end
  end

  describe '.get_description' do
    context 'with valid codes' do
      it 'returns description for "2062"' do
        expect(described_class.get_description('2062')).to eq('Sociedade Empresária Limitada')
      end

      it 'returns description for "101-5"' do
        expect(described_class.get_description('101-5')).to eq('Órgão Público do Poder Executivo Federal')
      end

      it 'returns description for "1015"' do
        expect(described_class.get_description('1015')).to eq('Órgão Público do Poder Executivo Federal')
      end

      it 'returns description for "2305"' do
        expect(described_class.get_description('2305')).to eq('Empresa Individual de Responsabilidade Limitada')
      end

      it 'returns description for "3123"' do
        expect(described_class.get_description('3123')).to eq('Partido Político')
      end

      it 'returns description for "4022"' do
        expect(described_class.get_description('4022')).to eq('Segurado Especial')
      end

      it 'returns description for "5002"' do
        expect(described_class.get_description('5002')).to eq('Organização Internacional e Outras Instituições Extraterritoriais')
      end

      it 'returns description for "2046" (SA Aberta)' do
        expect(described_class.get_description('2046')).to eq('Sociedade Anônima Aberta')
      end

      it 'returns description for "2054" (SA Fechada)' do
        expect(described_class.get_description('2054')).to eq('Sociedade Anônima Fechada')
      end

      it 'returns description for "2143" (Cooperativa)' do
        expect(described_class.get_description('2143')).to eq('Cooperativa')
      end
    end

    context 'with invalid codes' do
      it 'returns nil for "0000"' do
        expect(described_class.get_description('0000')).to be_nil
      end

      it 'returns nil for "9999"' do
        expect(described_class.get_description('9999')).to be_nil
      end

      it 'returns nil for invalid format' do
        expect(described_class.get_description('invalid')).to be_nil
      end

      it 'returns nil for nil input' do
        expect(described_class.get_description(nil)).to be_nil
      end

      it 'returns nil for empty string' do
        expect(described_class.get_description('')).to be_nil
      end
    end

    context 'with hyphenated format' do
      it 'returns description for "206-2"' do
        expect(described_class.get_description('206-2')).to eq('Sociedade Empresária Limitada')
      end

      it 'returns description for "230-5"' do
        expect(described_class.get_description('230-5')).to eq('Empresa Individual de Responsabilidade Limitada')
      end
    end
  end

  describe '.list_all' do
    it 'returns a hash' do
      expect(described_class.list_all).to be_a(Hash)
    end

    it 'returns all legal nature codes' do
      all_codes = described_class.list_all
      expect(all_codes.size).to eq(64)
    end

    it 'includes known codes' do
      all_codes = described_class.list_all
      expect(all_codes).to include('2062' => 'Sociedade Empresária Limitada')
      expect(all_codes).to include('1015' => 'Órgão Público do Poder Executivo Federal')
      expect(all_codes).to include('3123' => 'Partido Político')
    end

    it 'returns a copy (not the original)' do
      codes1 = described_class.list_all
      codes2 = described_class.list_all
      expect(codes1).not_to be(codes2)
    end

    it 'returned hash is mutable without affecting original' do
      codes = described_class.list_all
      codes['9999'] = 'Test'
      expect(described_class.list_all).not_to include('9999')
    end
  end

  describe '.list_by_category' do
    context 'category 1 (Administração Pública)' do
      it 'returns all category 1 codes' do
        category1 = described_class.list_by_category(1)
        expect(category1).to be_a(Hash)
        expect(category1.keys.all? { |k| k.start_with?('1') }).to be true
      end

      it 'includes known category 1 codes' do
        category1 = described_class.list_by_category(1)
        expect(category1).to include('1015' => 'Órgão Público do Poder Executivo Federal')
        expect(category1).to include('1104' => 'Autarquia Federal')
      end

      it 'accepts category as string' do
        expect(described_class.list_by_category('1')).to be_a(Hash)
      end
    end

    context 'category 2 (Entidades Empresariais)' do
      it 'returns all category 2 codes' do
        category2 = described_class.list_by_category(2)
        expect(category2).to be_a(Hash)
        expect(category2.keys.all? { |k| k.start_with?('2') }).to be true
      end

      it 'includes known category 2 codes' do
        category2 = described_class.list_by_category(2)
        expect(category2).to include('2062' => 'Sociedade Empresária Limitada')
        expect(category2).to include('2305' => 'Empresa Individual de Responsabilidade Limitada')
      end
    end

    context 'category 3 (Entidades Sem Fins Lucrativos)' do
      it 'returns all category 3 codes' do
        category3 = described_class.list_by_category(3)
        expect(category3).to be_a(Hash)
        expect(category3.keys.all? { |k| k.start_with?('3') }).to be true
      end

      it 'includes known category 3 codes' do
        category3 = described_class.list_by_category(3)
        expect(category3).to include('3123' => 'Partido Político')
        expect(category3).to include('3050' => 'Organização da Sociedade Civil de Interesse Público (Oscip)')
      end
    end

    context 'category 4 (Pessoas Físicas)' do
      it 'returns all category 4 codes' do
        category4 = described_class.list_by_category(4)
        expect(category4).to be_a(Hash)
        expect(category4.keys.all? { |k| k.start_with?('4') }).to be true
      end

      it 'includes known category 4 codes' do
        category4 = described_class.list_by_category(4)
        expect(category4).to include('4014' => 'Empresa Individual Imobiliária')
        expect(category4).to include('4022' => 'Segurado Especial')
      end
    end

    context 'category 5 (Organizações Internacionais)' do
      it 'returns all category 5 codes' do
        category5 = described_class.list_by_category(5)
        expect(category5).to be_a(Hash)
        expect(category5.keys.all? { |k| k.start_with?('5') }).to be true
      end

      it 'includes the category 5 code' do
        category5 = described_class.list_by_category(5)
        expect(category5).to include('5002' => 'Organização Internacional e Outras Instituições Extraterritoriais')
      end
    end

    context 'with invalid categories' do
      it 'returns empty hash for category 0' do
        expect(described_class.list_by_category(0)).to eq({})
      end

      it 'returns empty hash for category 6' do
        expect(described_class.list_by_category(6)).to eq({})
      end

      it 'returns empty hash for negative category' do
        expect(described_class.list_by_category(-1)).to eq({})
      end

      it 'returns empty hash for non-numeric string' do
        expect(described_class.list_by_category('invalid')).to eq({})
      end
    end
  end

  describe '.get_category' do
    context 'with valid codes' do
      it 'returns 1 for category 1 codes' do
        expect(described_class.get_category('1015')).to eq(1)
        expect(described_class.get_category('1104')).to eq(1)
      end

      it 'returns 2 for category 2 codes' do
        expect(described_class.get_category('2062')).to eq(2)
        expect(described_class.get_category('2305')).to eq(2)
      end

      it 'returns 3 for category 3 codes' do
        expect(described_class.get_category('3123')).to eq(3)
        expect(described_class.get_category('3050')).to eq(3)
      end

      it 'returns 4 for category 4 codes' do
        expect(described_class.get_category('4014')).to eq(4)
        expect(described_class.get_category('4022')).to eq(4)
      end

      it 'returns 5 for category 5 codes' do
        expect(described_class.get_category('5002')).to eq(5)
      end
    end

    context 'with hyphenated format' do
      it 'returns category for "206-2"' do
        expect(described_class.get_category('206-2')).to eq(2)
      end

      it 'returns category for "101-5"' do
        expect(described_class.get_category('101-5')).to eq(1)
      end
    end

    context 'with invalid codes' do
      it 'returns nil for non-existent code' do
        expect(described_class.get_category('9999')).to be_nil
      end

      it 'returns nil for invalid format' do
        expect(described_class.get_category('invalid')).to be_nil
      end

      it 'returns nil for nil input' do
        expect(described_class.get_category(nil)).to be_nil
      end

      it 'returns nil for empty string' do
        expect(described_class.get_category('')).to be_nil
      end
    end
  end

  describe 'integration tests' do
    it 'validates and retrieves description for the same code' do
      code = '2062'
      expect(described_class.is_valid(code)).to be true
      expect(described_class.get_description(code)).to eq('Sociedade Empresária Limitada')
    end

    it 'retrieves category and description for the same code' do
      code = '3123'
      expect(described_class.get_category(code)).to eq(3)
      expect(described_class.get_description(code)).to eq('Partido Político')
    end

    it 'lists all codes from a category and validates each one' do
      category2 = described_class.list_by_category(2)
      category2.each_key do |code|
        expect(described_class.is_valid(code)).to be true
      end
    end

    it 'all codes in list_all are valid' do
      all_codes = described_class.list_all
      all_codes.each_key do |code|
        expect(described_class.is_valid(code)).to be true
      end
    end
  end
end
