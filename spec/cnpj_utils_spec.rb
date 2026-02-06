require 'spec_helper'

describe BrazilianUtils::CNPJUtils do
  describe '.remove_symbols and .sieve' do
    it 'removes dots, slashes, and dashes from CNPJ' do
      expect(BrazilianUtils::CNPJUtils.remove_symbols('12.345/6789-01')).to eq('12345678901')
    end

    it 'removes symbols from another format' do
      expect(BrazilianUtils::CNPJUtils.remove_symbols('98/76.543-2101')).to eq('98765432101')
    end

    it 'sieve method works the same as remove_symbols' do
      expect(BrazilianUtils::CNPJUtils.sieve('12.345/6789-01')).to eq('12345678901')
    end

    it 'handles CNPJ with no symbols' do
      expect(BrazilianUtils::CNPJUtils.remove_symbols('12345678901234')).to eq('12345678901234')
    end

    it 'returns empty string for nil' do
      expect(BrazilianUtils::CNPJUtils.remove_symbols(nil)).to eq('')
    end
  end

  describe '.display' do
    it 'formats valid 14-digit CNPJ' do
      expect(BrazilianUtils::CNPJUtils.display('12345678901234')).to eq('12.345.678/9012-34')
    end

    it 'formats another valid CNPJ' do
      expect(BrazilianUtils::CNPJUtils.display('98765432100100')).to eq('98.765.432/1001-00')
    end

    it 'returns nil for CNPJ with all same digits' do
      expect(BrazilianUtils::CNPJUtils.display('00000000000000')).to be_nil
      expect(BrazilianUtils::CNPJUtils.display('11111111111111')).to be_nil
    end

    it 'returns nil for CNPJ with wrong length' do
      expect(BrazilianUtils::CNPJUtils.display('123456789012')).to be_nil
      expect(BrazilianUtils::CNPJUtils.display('123456789012345')).to be_nil
    end

    it 'returns nil for CNPJ with non-digits' do
      expect(BrazilianUtils::CNPJUtils.display('1234567890123A')).to be_nil
    end
  end

  describe '.format_cnpj' do
    it 'formats valid CNPJ' do
      expect(BrazilianUtils::CNPJUtils.format_cnpj('03560714000142')).to eq('03.560.714/0001-42')
    end

    it 'returns nil for invalid CNPJ' do
      expect(BrazilianUtils::CNPJUtils.format_cnpj('98765432100100')).to be_nil
    end

    it 'returns nil for CNPJ with wrong length' do
      expect(BrazilianUtils::CNPJUtils.format_cnpj('123456789012')).to be_nil
    end

    it 'returns nil for CNPJ with all same digits' do
      expect(BrazilianUtils::CNPJUtils.format_cnpj('00000000000000')).to be_nil
    end
  end

  describe '.validate' do
    it 'validates correct CNPJ' do
      expect(BrazilianUtils::CNPJUtils.validate('03560714000142')).to be true
    end

    it 'rejects incorrect CNPJ' do
      expect(BrazilianUtils::CNPJUtils.validate('00111222000133')).to be false
    end

    it 'rejects CNPJ with all same digits' do
      expect(BrazilianUtils::CNPJUtils.validate('00000000000000')).to be false
      expect(BrazilianUtils::CNPJUtils.validate('11111111111111')).to be false
      expect(BrazilianUtils::CNPJUtils.validate('22222222222222')).to be false
    end

    it 'rejects CNPJ with wrong length' do
      expect(BrazilianUtils::CNPJUtils.validate('123456789012')).to be false
      expect(BrazilianUtils::CNPJUtils.validate('123456789012345')).to be false
    end

    it 'rejects CNPJ with non-digits' do
      expect(BrazilianUtils::CNPJUtils.validate('1234567890123A')).to be false
    end

    it 'rejects empty string' do
      expect(BrazilianUtils::CNPJUtils.validate('')).to be false
    end
  end

  describe '.valid?' do
    it 'validates correct CNPJ' do
      expect(BrazilianUtils::CNPJUtils.valid?('03560714000142')).to be true
    end

    it 'rejects incorrect CNPJ' do
      expect(BrazilianUtils::CNPJUtils.valid?('00111222000133')).to be false
    end

    it 'rejects non-string input' do
      expect(BrazilianUtils::CNPJUtils.valid?(nil)).to be false
      expect(BrazilianUtils::CNPJUtils.valid?(3560714000142)).to be false
    end

    it 'validates multiple known valid CNPJs' do
      valid_cnpjs = [
        '03560714000142',
        '11222333000181',
        '11444777000161'
      ]

      valid_cnpjs.each do |cnpj|
        expect(BrazilianUtils::CNPJUtils.valid?(cnpj)).to be(true), "Expected #{cnpj} to be valid"
      end
    end

    it 'rejects multiple known invalid CNPJs' do
      invalid_cnpjs = [
        '00111222000133',
        '11222333000180',
        '11444777000160',
        '00000000000000',
        '12345678901234'
      ]

      invalid_cnpjs.each do |cnpj|
        expect(BrazilianUtils::CNPJUtils.valid?(cnpj)).to be(false), "Expected #{cnpj} to be invalid"
      end
    end
  end

  describe '.generate' do
    it 'generates valid CNPJ with default branch' do
      cnpj = BrazilianUtils::CNPJUtils.generate
      expect(cnpj).to match(/^\d{14}$/)
      expect(BrazilianUtils::CNPJUtils.valid?(cnpj)).to be true
    end

    it 'generates valid CNPJ with specified branch' do
      cnpj = BrazilianUtils::CNPJUtils.generate(branch: 1234)
      expect(cnpj).to match(/^\d{14}$/)
      expect(cnpj[8..11]).to eq('1234')
      expect(BrazilianUtils::CNPJUtils.valid?(cnpj)).to be true
    end

    it 'generates valid CNPJ with branch 1' do
      cnpj = BrazilianUtils::CNPJUtils.generate(branch: 1)
      expect(cnpj[8..11]).to eq('0001')
      expect(BrazilianUtils::CNPJUtils.valid?(cnpj)).to be true
    end

    it 'generates valid CNPJ with branch 0 (converts to 1)' do
      cnpj = BrazilianUtils::CNPJUtils.generate(branch: 0)
      expect(cnpj[8..11]).to eq('0001')
      expect(BrazilianUtils::CNPJUtils.valid?(cnpj)).to be true
    end

    it 'handles branch numbers greater than 9999' do
      cnpj = BrazilianUtils::CNPJUtils.generate(branch: 12345)
      # 12345 % 10000 = 2345
      expect(cnpj[8..11]).to eq('2345')
      expect(BrazilianUtils::CNPJUtils.valid?(cnpj)).to be true
    end

    it 'generates different CNPJs on multiple calls' do
      cnpjs = 10.times.map { BrazilianUtils::CNPJUtils.generate }
      expect(cnpjs.uniq.length).to be > 1
    end

    it 'all generated CNPJs are valid' do
      10.times do
        cnpj = BrazilianUtils::CNPJUtils.generate
        expect(BrazilianUtils::CNPJUtils.valid?(cnpj)).to be true
      end
    end
  end

  describe 'integration tests' do
    it 'can format a generated CNPJ' do
      cnpj = BrazilianUtils::CNPJUtils.generate
      formatted = BrazilianUtils::CNPJUtils.format_cnpj(cnpj)
      expect(formatted).to match(/^\d{2}\.\d{3}\.\d{3}\/\d{4}-\d{2}$/)
    end

    it 'can validate after removing symbols' do
      dirty_cnpj = '03.560.714/0001-42'
      clean_cnpj = BrazilianUtils::CNPJUtils.remove_symbols(dirty_cnpj)
      expect(BrazilianUtils::CNPJUtils.valid?(clean_cnpj)).to be true
    end

    it 'complete workflow: generate, format, clean, validate' do
      # Generate
      cnpj = BrazilianUtils::CNPJUtils.generate(branch: 42)
      expect(BrazilianUtils::CNPJUtils.valid?(cnpj)).to be true

      # Format
      formatted = BrazilianUtils::CNPJUtils.format_cnpj(cnpj)
      expect(formatted).not_to be_nil

      # Clean
      cleaned = BrazilianUtils::CNPJUtils.remove_symbols(formatted)
      expect(cleaned).to eq(cnpj)

      # Validate
      expect(BrazilianUtils::CNPJUtils.valid?(cleaned)).to be true
    end
  end

  describe 'edge cases' do
    it 'handles CNPJ with leading zeros' do
      expect(BrazilianUtils::CNPJUtils.valid?('00000000000191')).to be true
    end

    it 'rejects CNPJ with wrong check digits' do
      expect(BrazilianUtils::CNPJUtils.valid?('03560714000143')).to be false
      expect(BrazilianUtils::CNPJUtils.valid?('03560714000141')).to be false
    end
  end

  describe 'private methods' do
    it 'does not expose hashdigit' do
      expect(BrazilianUtils::CNPJUtils).not_to respond_to(:hashdigit)
    end

    it 'does not expose checksum' do
      expect(BrazilianUtils::CNPJUtils).not_to respond_to(:checksum)
    end
  end
end
