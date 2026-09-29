require 'spec_helper'

describe BrazilianUtils::CurrencyUtils do
  describe '.format_currency' do
    it 'formats positive float value (no symbol by default)' do
      expect(BrazilianUtils::CurrencyUtils.format_currency(1234.56)).to eq('1.234,56')
    end

    it 'formats zero' do
      expect(BrazilianUtils::CurrencyUtils.format_currency(0)).to eq('0,00')
    end

    it 'formats negative value' do
      expect(BrazilianUtils::CurrencyUtils.format_currency(-9876.54)).to eq('-9.876,54')
    end

    it 'formats integer value' do
      expect(BrazilianUtils::CurrencyUtils.format_currency(1000)).to eq('1.000,00')
    end

    it 'formats string value with dot decimal separator' do
      expect(BrazilianUtils::CurrencyUtils.format_currency('2500.75')).to eq('2.500,75')
    end

    it 'formats string value already in Brazilian format' do
      expect(BrazilianUtils::CurrencyUtils.format_currency('1.234,56')).to eq('1.234,56')
    end

    it 'formats string value with R$ symbol already present' do
      expect(BrazilianUtils::CurrencyUtils.format_currency('R$ 1.234,56')).to eq('1.234,56')
    end

    it 'formats large value with thousands separator' do
      expect(BrazilianUtils::CurrencyUtils.format_currency(1234567.89)).to eq('1.234.567,89')
    end

    it 'formats very large value' do
      expect(BrazilianUtils::CurrencyUtils.format_currency(1234567890.12)).to eq('1.234.567.890,12')
    end

    it 'formats value with one decimal place (rounds to 2)' do
      expect(BrazilianUtils::CurrencyUtils.format_currency(10.5)).to eq('10,50')
    end

    it 'formats value with many decimal places (rounds to 2)' do
      expect(BrazilianUtils::CurrencyUtils.format_currency(10.12345)).to eq('10,12')
    end

    it 'returns nil for invalid string' do
      expect(BrazilianUtils::CurrencyUtils.format_currency('invalid')).to be_nil
    end

    it 'returns nil for nil value' do
      expect(BrazilianUtils::CurrencyUtils.format_currency(nil)).to be_nil
    end

    it 'formats small decimal value' do
      expect(BrazilianUtils::CurrencyUtils.format_currency(0.50)).to eq('0,50')
    end

    it 'formats negative small value' do
      expect(BrazilianUtils::CurrencyUtils.format_currency(-0.01)).to eq('-0,01')
    end

    it 'adds the R$ symbol when options[:symbol] is true' do
      expect(BrazilianUtils::CurrencyUtils.format_currency(1234.56, symbol: true)).to eq('R$ 1.234,56')
    end

    it 'supports a custom precision' do
      expect(BrazilianUtils::CurrencyUtils.format_currency(1000.5, precision: 1)).to eq('1.000,5')
    end
  end

  describe '.parse_currency' do
    it 'parses a value with the R$ symbol' do
      expect(BrazilianUtils::CurrencyUtils.parse_currency('R$ 1.234,56')).to eq(1234.56)
    end

    it 'parses a comma-decimal value' do
      expect(BrazilianUtils::CurrencyUtils.parse_currency('1234,56')).to eq(1234.56)
    end

    it 'parses cents' do
      expect(BrazilianUtils::CurrencyUtils.parse_currency('R$ 0,50')).to eq(0.5)
    end

    it 'parses millions' do
      expect(BrazilianUtils::CurrencyUtils.parse_currency('1.000.000,50')).to eq(1_000_000.5)
    end

    it 'parses a negative value' do
      expect(BrazilianUtils::CurrencyUtils.parse_currency('-1.234,56')).to eq(-1234.56)
    end

    it 'parses zero' do
      expect(BrazilianUtils::CurrencyUtils.parse_currency('0,00')).to eq(0)
    end

    it 'reads digits with no separator as cents' do
      expect(BrazilianUtils::CurrencyUtils.parse_currency('1234')).to eq(12.34)
    end

    it 'returns 0 for an empty string' do
      expect(BrazilianUtils::CurrencyUtils.parse_currency('')).to eq(0)
    end

    it 'has an alias .parse' do
      expect(BrazilianUtils::CurrencyUtils.parse('R$ 1.234,56')).to eq(1234.56)
    end
  end

  describe '.convert_real_to_text' do
    context 'with zero values' do
      it 'converts 0.00 to text' do
        expect(BrazilianUtils::CurrencyUtils.convert_real_to_text(0.00)).to eq('zero reais')
      end

      it 'converts 0 to text' do
        expect(BrazilianUtils::CurrencyUtils.convert_real_to_text(0)).to eq('zero reais')
      end
    end

    context 'with only reais (no centavos)' do
      it 'converts 1 real' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(1.00)
        expect(result).to eq('um real')
      end

      it 'converts 2 reais' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(2.00)
        expect(result).to eq('dois reais')
      end

      it 'converts 10 reais' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(10.00)
        expect(result).to eq('dez reais')
      end

      it 'converts 100 reais' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(100.00)
        expect(result).to eq('cem reais')
      end

      it 'converts 1000 reais' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(1000.00)
        expect(result).to eq('mil reais')
      end
    end

    context 'with only centavos (no reais)' do
      it 'converts 0.01 to text' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(0.01)
        expect(result).to eq('um centavo')
      end

      it 'converts 0.50 to text' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(0.50)
        expect(result).to eq('cinquenta centavos')
      end

      it 'converts 0.99 to text' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(0.99)
        expect(result).to eq('noventa e nove centavos')
      end
    end

    context 'with reais and centavos' do
      it 'converts 1.50 to text' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(1.50)
        expect(result).to eq('um real e cinquenta centavos')
      end

      it 'converts 1523.45 to text' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(1523.45)
        expect(result).to eq('mil quinhentos e vinte e três reais e quarenta e cinco centavos')
      end

      it 'converts 2.01 to text' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(2.01)
        expect(result).to eq('dois reais e um centavo')
      end
    end

    context 'with large values' do
      it 'converts 1 million' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(1_000_000.00)
        expect(result).to eq('um milhão de reais')
      end

      it 'converts 2 million' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(2_000_000.00)
        expect(result).to eq('dois milhões de reais')
      end

      it 'converts 1 billion' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(1_000_000_000.00)
        expect(result).to eq('um bilhão de reais')
      end

      it 'converts complex large value' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(1_234_567.89)
        expect(result).to match(/milhão/)
        expect(result).to match(/reais/)
        expect(result).to match(/centavos/)
      end
    end

    context 'with negative values' do
      it 'converts negative value' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(-10.50)
        expect(result).to start_with('menos')
        expect(result).to include('reais')
      end

      it 'converts negative centavos only' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(-0.50)
        expect(result).to start_with('menos')
        expect(result).to include('centavos')
      end
    end

    context 'with rounding' do
      it 'truncates (does not round) values with more than 2 decimal places' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(1.999)
        expect(result).to eq('um real e noventa e nove centavos')
      end

      it 'truncates to avoid floating point issues' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(0.555)
        expect(result).to eq('cinquenta e cinco centavos')
      end
    end

    context 'with invalid values' do
      it 'returns nil for invalid string' do
        expect(BrazilianUtils::CurrencyUtils.convert_real_to_text('invalid')).to be_nil
      end

      it 'returns nil for nil value' do
        expect(BrazilianUtils::CurrencyUtils.convert_real_to_text(nil)).to be_nil
      end

      it 'returns nil for value exceeding 1 quadrillion' do
        expect(BrazilianUtils::CurrencyUtils.convert_real_to_text(1_000_000_000_000_001.00)).to be_nil
      end
    end

    context 'with special number cases' do
      it 'converts 11 reais' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(11.00)
        expect(result).to eq('onze reais')
      end

      it 'converts 15 reais' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(15.00)
        expect(result).to eq('quinze reais')
      end

      it 'converts 20 reais' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(20.00)
        expect(result).to eq('vinte reais')
      end

      it 'converts 21 reais' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(21.00)
        expect(result).to eq('vinte e um reais')
      end

      it 'converts 101 reais' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(101.00)
        expect(result).to eq('cento e um reais')
      end

      it 'converts 200 reais' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(200.00)
        expect(result).to eq('duzentos reais')
      end
    end

    context 'with string input' do
      it 'converts string to text' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text('100.50')
        expect(result).to eq('cem reais e cinquenta centavos')
      end
    end
  end

  describe 'integration tests' do
    it 'formats and converts the same value' do
      value = 1234.56
      formatted = BrazilianUtils::CurrencyUtils.format_currency(value)
      text = BrazilianUtils::CurrencyUtils.convert_real_to_text(value)

      expect(formatted).to eq('1.234,56')
      expect(text).to include('mil')
      expect(text).to include('reais')
      expect(text).to include('centavos')
    end
  end

  describe 'private methods' do
    it 'does not expose number_to_words' do
      expect(BrazilianUtils::CurrencyUtils).not_to respond_to(:number_to_words)
    end

    it 'does not expose convert_group' do
      expect(BrazilianUtils::CurrencyUtils).not_to respond_to(:convert_group)
    end
  end
end
