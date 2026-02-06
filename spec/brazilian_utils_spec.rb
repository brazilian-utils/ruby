require 'spec_helper'

describe BrazilianUtils::CPFUtils do
  describe '.remove_symbols and .sieve' do
    it 'removes dots and dashes from CPF' do
      expect(BrazilianUtils::CPFUtils.remove_symbols('123.456.789-01')).to eq('12345678901')
    end

    it 'removes symbols from another format' do
      expect(BrazilianUtils::CPFUtils.remove_symbols('987-654-321.01')).to eq('98765432101')
    end

    it 'sieve method works the same as remove_symbols' do
      expect(BrazilianUtils::CPFUtils.sieve('123.456.789-01')).to eq('12345678901')
    end

    it 'handles CPF with no symbols' do
      expect(BrazilianUtils::CPFUtils.remove_symbols('12345678901')).to eq('12345678901')
    end

    it 'returns empty string for nil' do
      expect(BrazilianUtils::CPFUtils.remove_symbols(nil)).to eq('')
    end
  end

  describe '.display' do
    it 'formats valid 11-digit CPF' do
      expect(BrazilianUtils::CPFUtils.display('12345678901')).to eq('123.456.789-01')
    end

    it 'formats another valid CPF' do
      expect(BrazilianUtils::CPFUtils.display('98765432101')).to eq('987.654.321-01')
    end

    it 'returns nil for CPF with all same digits' do
      expect(BrazilianUtils::CPFUtils.display('00000000000')).to be_nil
      expect(BrazilianUtils::CPFUtils.display('11111111111')).to be_nil
    end

    it 'returns nil for CPF with wrong length' do
      expect(BrazilianUtils::CPFUtils.display('123456789')).to be_nil
      expect(BrazilianUtils::CPFUtils.display('123456789012')).to be_nil
    end

    it 'returns nil for CPF with non-digits' do
      expect(BrazilianUtils::CPFUtils.display('1234567890A')).to be_nil
    end
  end

  describe '.format_cpf' do
    it 'formats valid CPF' do
      expect(BrazilianUtils::CPFUtils.format_cpf('82178537464')).to eq('821.785.374-64')
    end

    it 'formats another valid CPF' do
      expect(BrazilianUtils::CPFUtils.format_cpf('55550207753')).to eq('555.502.077-53')
    end

    it 'returns nil for invalid CPF' do
      expect(BrazilianUtils::CPFUtils.format_cpf('12345678901')).to be_nil
    end

    it 'returns nil for CPF with wrong length' do
      expect(BrazilianUtils::CPFUtils.format_cpf('123456789')).to be_nil
    end

    it 'returns nil for CPF with all same digits' do
      expect(BrazilianUtils::CPFUtils.format_cpf('00000000000')).to be_nil
    end
  end

  describe '.validate' do
    it 'validates correct CPF' do
      expect(BrazilianUtils::CPFUtils.validate('82178537464')).to be true
    end

    it 'validates another correct CPF' do
      expect(BrazilianUtils::CPFUtils.validate('55550207753')).to be true
    end

    it 'rejects incorrect CPF' do
      expect(BrazilianUtils::CPFUtils.validate('12345678901')).to be false
    end

    it 'rejects CPF with all same digits' do
      %w[
        00000000000
        11111111111
        22222222222
        33333333333
        44444444444
        55555555555
        66666666666
        77777777777
        88888888888
        99999999999
      ].each do |cpf|
        expect(BrazilianUtils::CPFUtils.validate(cpf)).to be false
      end
    end

    it 'rejects CPF with wrong length' do
      expect(BrazilianUtils::CPFUtils.validate('123456789')).to be false
      expect(BrazilianUtils::CPFUtils.validate('123456789012')).to be false
    end

    it 'rejects CPF with non-digits' do
      expect(BrazilianUtils::CPFUtils.validate('1234567890A')).to be false
    end

    it 'rejects empty string' do
      expect(BrazilianUtils::CPFUtils.validate('')).to be false
    end
  end

  describe '.valid?' do
    it 'validates correct CPF' do
      expect(BrazilianUtils::CPFUtils.valid?('82178537464')).to be true
    end

    it 'validates another correct CPF' do
      expect(BrazilianUtils::CPFUtils.valid?('55550207753')).to be true
    end

    it 'validates known valid CPF (original test)' do
      expect(BrazilianUtils::CPFUtils.valid?('41840660546')).to be true
    end

    it 'rejects nil' do
      expect(BrazilianUtils::CPFUtils.valid?(nil)).to be false
    end

    it 'rejects empty string' do
      expect(BrazilianUtils::CPFUtils.valid?('')).to be false
    end

    it 'rejects non-string input' do
      expect(BrazilianUtils::CPFUtils.valid?(82178537464)).to be false
    end

    it 'rejects CPF with symbols (must be numbers only)' do
      expect(BrazilianUtils::CPFUtils.valid?('821.785.374-64')).to be false
    end

    %w[
      11111111111
      22222222222
      33333333333
      44444444444
      55555555555
      66666666666
      77777777777
      88888888888
      99999999999
    ].each do |invalid_cpf|
      it "rejects invalid CPF sequence #{invalid_cpf}" do
        expect(BrazilianUtils::CPFUtils.valid?(invalid_cpf)).to be false
      end
    end

    it 'validates multiple known valid CPFs' do
      valid_cpfs = [
        '82178537464',
        '55550207753',
        '41840660546',
        '00000000191',
        '00000000272'
      ]

      valid_cpfs.each do |cpf|
        expect(BrazilianUtils::CPFUtils.valid?(cpf)).to be(true), "Expected #{cpf} to be valid"
      end
    end
  end

  describe '.generate' do
    it 'generates valid CPF' do
      cpf = BrazilianUtils::CPFUtils.generate
      expect(cpf).to match(/^\d{11}$/)
      expect(BrazilianUtils::CPFUtils.valid?(cpf)).to be true
    end

    it 'generates CPF with 11 digits' do
      cpf = BrazilianUtils::CPFUtils.generate
      expect(cpf.length).to eq(11)
    end

    it 'generates different CPFs on multiple calls' do
      cpfs = 10.times.map { BrazilianUtils::CPFUtils.generate }
      expect(cpfs.uniq.length).to be > 1
    end

    it 'all generated CPFs are valid' do
      10.times do
        cpf = BrazilianUtils::CPFUtils.generate
        expect(BrazilianUtils::CPFUtils.valid?(cpf)).to be true
      end
    end

    it 'generated CPF does not start with 0' do
      # Since we use rand(1..999_999_998), it should never be all zeros
      cpf = BrazilianUtils::CPFUtils.generate
      expect(cpf[0]).not_to eq('0')
    end
  end

  describe 'integration tests' do
    it 'can format a generated CPF' do
      cpf = BrazilianUtils::CPFUtils.generate
      formatted = BrazilianUtils::CPFUtils.format_cpf(cpf)
      expect(formatted).to match(/^\d{3}\.\d{3}\.\d{3}-\d{2}$/)
    end

    it 'can validate after removing symbols' do
      dirty_cpf = '821.785.374-64'
      clean_cpf = BrazilianUtils::CPFUtils.remove_symbols(dirty_cpf)
      expect(BrazilianUtils::CPFUtils.valid?(clean_cpf)).to be true
    end

    it 'complete workflow: generate, format, clean, validate' do
      # Generate
      cpf = BrazilianUtils::CPFUtils.generate
      expect(BrazilianUtils::CPFUtils.valid?(cpf)).to be true

      # Format
      formatted = BrazilianUtils::CPFUtils.format_cpf(cpf)
      expect(formatted).not_to be_nil

      # Clean
      cleaned = BrazilianUtils::CPFUtils.remove_symbols(formatted)
      expect(cleaned).to eq(cpf)

      # Validate
      expect(BrazilianUtils::CPFUtils.valid?(cleaned)).to be true
    end
  end

  describe 'edge cases' do
    it 'handles CPF with leading zeros' do
      expect(BrazilianUtils::CPFUtils.valid?('00000000191')).to be true
    end

    it 'rejects CPF with wrong check digits' do
      expect(BrazilianUtils::CPFUtils.valid?('82178537465')).to be false
      expect(BrazilianUtils::CPFUtils.valid?('82178537454')).to be false
    end
  end

  describe 'private methods' do
    it 'does not expose hashdigit' do
      expect(BrazilianUtils::CPFUtils).not_to respond_to(:hashdigit)
    end

    it 'does not expose checksum' do
      expect(BrazilianUtils::CPFUtils).not_to respond_to(:checksum)
    end
  end
end
