require 'spec_helper'

describe BrazilianUtils::CurrencyUtils do
  describe '.format_currency' do
    it 'formats positive float value' do
      expect(BrazilianUtils::CurrencyUtils.format_currency(1234.56)).to eq('R$ 1.234,56')
    end

    it 'formats zero' do
      expect(BrazilianUtils::CurrencyUtils.format_currency(0)).to eq('R$ 0,00')
    end

    it 'formats negative value' do
      expect(BrazilianUtils::CurrencyUtils.format_currency(-9876.54)).to eq('R$ -9.876,54')
    end

    it 'formats integer value' do
      expect(BrazilianUtils::CurrencyUtils.format_currency(1000)).to eq('R$ 1.000,00')
    end

    it 'formats string value' do
      expect(BrazilianUtils::CurrencyUtils.format_currency('2500.75')).to eq('R$ 2.500,75')
    end

    it 'formats large value with thousands separator' do
      expect(BrazilianUtils::CurrencyUtils.format_currency(1234567.89)).to eq('R$ 1.234.567,89')
    end

    it 'formats very large value' do
      expect(BrazilianUtils::CurrencyUtils.format_currency(1234567890.12)).to eq('R$ 1.234.567.890,12')
    end

    it 'formats value with one decimal place (rounds to 2)' do
      expect(BrazilianUtils::CurrencyUtils.format_currency(10.5)).to eq('R$ 10,50')
    end

    it 'formats value with many decimal places (rounds to 2)' do
      expect(BrazilianUtils::CurrencyUtils.format_currency(10.12345)).to eq('R$ 10,12')
    end

    it 'returns nil for invalid string' do
      expect(BrazilianUtils::CurrencyUtils.format_currency('invalid')).to be_nil
    end

    it 'returns nil for nil value' do
      expect(BrazilianUtils::CurrencyUtils.format_currency(nil)).to be_nil
    end

    it 'formats small decimal value' do
      expect(BrazilianUtils::CurrencyUtils.format_currency(0.50)).to eq('R$ 0,50')
    end

    it 'formats negative small value' do
      expect(BrazilianUtils::CurrencyUtils.format_currency(-0.01)).to eq('R$ -0,01')
    end
  end

  describe '.convert_real_to_text' do
    context 'with zero values' do
      it 'converts 0.00 to text' do
        expect(BrazilianUtils::CurrencyUtils.convert_real_to_text(0.00)).to eq('Zero reais')
      end

      it 'converts 0 to text' do
        expect(BrazilianUtils::CurrencyUtils.convert_real_to_text(0)).to eq('Zero reais')
      end
    end

    context 'with only reais (no centavos)' do
      it 'converts 1 real' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(1.00)
        expect(result).to eq('Um real')
      end

      it 'converts 2 reais' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(2.00)
        expect(result).to eq('Dois reais')
      end

      it 'converts 10 reais' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(10.00)
        expect(result).to eq('Dez reais')
      end

      it 'converts 100 reais' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(100.00)
        expect(result).to eq('Cem reais')
      end

      it 'converts 1000 reais' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(1000.00)
        expect(result).to eq('Mil reais')
      end
    end

    context 'with only centavos (no reais)' do
      it 'converts 0.01 to text' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(0.01)
        expect(result).to eq('Um centavo')
      end

      it 'converts 0.50 to text' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(0.50)
        expect(result).to eq('Cinquenta centavos')
      end

      it 'converts 0.99 to text' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(0.99)
        expect(result).to eq('Noventa e nove centavos')
      end
    end

    context 'with reais and centavos' do
      it 'converts 1.50 to text' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(1.50)
        expect(result).to eq('Um real e cinquenta centavos')
      end

      it 'converts 1523.45 to text' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(1523.45)
        expect(result).to eq('Mil, quinhentos e vinte e três reais e quarenta e cinco centavos')
      end

      it 'converts 2.01 to text' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(2.01)
        expect(result).to eq('Dois reais e um centavo')
      end
    end

    context 'with large values' do
      it 'converts 1 million' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(1_000_000.00)
        expect(result).to eq('Um milhão de reais')
      end

      it 'converts 2 million' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(2_000_000.00)
        expect(result).to eq('Dois milhões de reais')
      end

      it 'converts 1 billion' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(1_000_000_000.00)
        expect(result).to eq('Um bilhão de reais')
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
        expect(result).to start_with('Menos')
        expect(result).to include('reais')
      end

      it 'converts negative centavos only' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(-0.50)
        expect(result).to start_with('Menos')
        expect(result).to include('centavos')
      end
    end

    context 'with rounding' do
      it 'rounds down values with more than 2 decimal places' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(1.999)
        expect(result).to eq('Um real e noventa e nove centavos')
      end

      it 'rounds down to avoid floating point issues' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(0.555)
        expect(result).to eq('Cinquenta e cinco centavos')
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
        expect(result).to eq('Onze reais')
      end

      it 'converts 15 reais' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(15.00)
        expect(result).to eq('Quinze reais')
      end

      it 'converts 20 reais' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(20.00)
        expect(result).to eq('Vinte reais')
      end

      it 'converts 21 reais' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(21.00)
        expect(result).to eq('Vinte e um reais')
      end

      it 'converts 101 reais' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(101.00)
        expect(result).to eq('Cento e um reais')
      end

      it 'converts 200 reais' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text(200.00)
        expect(result).to eq('Duzentos reais')
      end
    end

    context 'with string input' do
      it 'converts string to text' do
        result = BrazilianUtils::CurrencyUtils.convert_real_to_text('100.50')
        expect(result).to eq('Cem reais e cinquenta centavos')
      end
    end
  end

  describe 'integration tests' do
    it 'formats and converts the same value' do
      value = 1234.56
      formatted = BrazilianUtils::CurrencyUtils.format_currency(value)
      text = BrazilianUtils::CurrencyUtils.convert_real_to_text(value)
      
      expect(formatted).to eq('R$ 1.234,56')
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
