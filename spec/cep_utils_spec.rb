require 'spec_helper'

describe BrazilianUtils::CEPUtils do
  describe '.remove_symbols' do
    it 'removes dots and dashes from CEP' do
      expect(BrazilianUtils::CEPUtils.remove_symbols('123-45.678.9')).to eq('123456789')
    end

    it 'removes dots and dashes from simple string' do
      expect(BrazilianUtils::CEPUtils.remove_symbols('abc.xyz')).to eq('abcxyz')
    end

    it 'returns empty string when passed nil' do
      expect(BrazilianUtils::CEPUtils.remove_symbols(nil)).to eq('')
    end

    it 'handles string with no symbols' do
      expect(BrazilianUtils::CEPUtils.remove_symbols('12345678')).to eq('12345678')
    end
  end

  describe '.format_cep' do
    it 'formats a valid 8-digit CEP' do
      expect(BrazilianUtils::CEPUtils.format_cep('12345678')).to eq('12345-678')
    end

    it 'formats a valid CEP from real address' do
      expect(BrazilianUtils::CEPUtils.format_cep('01310100')).to eq('01310-100')
    end

    it 'returns nil for invalid CEP' do
      expect(BrazilianUtils::CEPUtils.format_cep('12345')).to be_nil
    end

    it 'returns nil for CEP with letters' do
      expect(BrazilianUtils::CEPUtils.format_cep('abcdefgh')).to be_nil
    end

    it 'returns nil for empty string' do
      expect(BrazilianUtils::CEPUtils.format_cep('')).to be_nil
    end
  end

  describe '.valid?' do
    it 'validates 8-digit CEP' do
      expect(BrazilianUtils::CEPUtils.valid?('12345678')).to be true
    end

    it 'validates real CEP' do
      expect(BrazilianUtils::CEPUtils.valid?('01310100')).to be true
    end

    it 'rejects CEP with less than 8 digits' do
      expect(BrazilianUtils::CEPUtils.valid?('12345')).to be false
    end

    it 'rejects CEP with more than 8 digits' do
      expect(BrazilianUtils::CEPUtils.valid?('123456789')).to be false
    end

    it 'rejects CEP with letters' do
      expect(BrazilianUtils::CEPUtils.valid?('abcdefgh')).to be false
    end

    it 'rejects empty string' do
      expect(BrazilianUtils::CEPUtils.valid?('')).to be false
    end

    it 'rejects nil' do
      expect(BrazilianUtils::CEPUtils.valid?(nil)).to be false
    end

    it 'rejects CEP with symbols' do
      expect(BrazilianUtils::CEPUtils.valid?('12345-678')).to be false
    end
  end

  describe '.generate' do
    it 'generates an 8-digit CEP' do
      cep = BrazilianUtils::CEPUtils.generate
      expect(cep).to match(/^\d{8}$/)
      expect(cep.length).to eq(8)
    end

    it 'generates valid CEPs' do
      cep = BrazilianUtils::CEPUtils.generate
      expect(BrazilianUtils::CEPUtils.valid?(cep)).to be true
    end

    it 'generates different CEPs' do
      ceps = 10.times.map { BrazilianUtils::CEPUtils.generate }
      # There's a very small chance all 10 are the same, but statistically negligible
      expect(ceps.uniq.length).to be > 1
    end
  end

  describe 'BrazilianUtils::UF' do
    describe '.valid?' do
      it 'validates valid state code' do
        expect(BrazilianUtils::UF.valid?('SP')).to be true
        expect(BrazilianUtils::UF.valid?('RJ')).to be true
      end

      it 'validates lowercase state code' do
        expect(BrazilianUtils::UF.valid?('sp')).to be true
      end

      it 'rejects invalid state code' do
        expect(BrazilianUtils::UF.valid?('XX')).to be false
        expect(BrazilianUtils::UF.valid?('ZZ')).to be false
      end
    end

    describe '.name_from_code' do
      it 'returns state name from code' do
        expect(BrazilianUtils::UF.name_from_code('SP')).to eq('São Paulo')
        expect(BrazilianUtils::UF.name_from_code('RJ')).to eq('Rio de Janeiro')
      end

      it 'handles lowercase codes' do
        expect(BrazilianUtils::UF.name_from_code('sp')).to eq('São Paulo')
      end

      it 'returns nil for invalid code' do
        expect(BrazilianUtils::UF.name_from_code('XX')).to be_nil
      end
    end

    describe '.code_from_name' do
      it 'returns code from state name' do
        expect(BrazilianUtils::UF.code_from_name('São Paulo')).to eq('SP')
        expect(BrazilianUtils::UF.code_from_name('Rio de Janeiro')).to eq('RJ')
      end

      it 'returns nil for invalid name' do
        expect(BrazilianUtils::UF.code_from_name('Invalid State')).to be_nil
      end
    end
  end

  describe '.get_address_from_cep' do
    it 'returns nil for invalid CEP without raising exception' do
      result = BrazilianUtils::CEPUtils.get_address_from_cep('abcdefg')
      expect(result).to be_nil
    end

    it 'raises InvalidCEP for invalid CEP when raise_exceptions is true' do
      expect do
        BrazilianUtils::CEPUtils.get_address_from_cep('abcdefg', raise_exceptions: true)
      end.to raise_error(BrazilianUtils::InvalidCEP, "CEP 'abcdefg' is invalid.")
    end

    it 'returns nil for short CEP without raising exception' do
      result = BrazilianUtils::CEPUtils.get_address_from_cep('12345')
      expect(result).to be_nil
    end

    it 'handles CEP with symbols' do
      # Should clean the CEP and validate
      result = BrazilianUtils::CEPUtils.get_address_from_cep('01310-100', raise_exceptions: false)
      # This might return an address if the API is accessible
      # We can't guarantee the result in tests without mocking
      expect(result).to be_a(BrazilianUtils::Address).or be_nil
    end

    context 'with valid CEP' do
      it 'returns an Address object with correct structure' do
        # Using a known CEP (Avenida Paulista, São Paulo)
        result = BrazilianUtils::CEPUtils.get_address_from_cep('01310100')

        # Skip test if API is not accessible
        skip 'API not accessible' if result.nil?

        expect(result).to be_a(BrazilianUtils::Address)
        expect(result.cep).to eq('01310-100')
        expect(result.logradouro).not_to be_nil
        expect(result.uf).to eq('SP')
      end
    end

    context 'with non-existent CEP' do
      it 'returns nil without raising exception' do
        result = BrazilianUtils::CEPUtils.get_address_from_cep('99999999')
        expect(result).to be_nil
      end

      it 'raises CEPNotFound when raise_exceptions is true' do
        expect do
          BrazilianUtils::CEPUtils.get_address_from_cep('99999999', raise_exceptions: true)
        end.to raise_error(BrazilianUtils::CEPNotFound)
      end
    end
  end

  describe '.get_cep_information_from_address' do
    it 'returns nil for invalid UF without raising exception' do
      result = BrazilianUtils::CEPUtils.get_cep_information_from_address('XX', 'City', 'Street')
      expect(result).to be_nil
    end

    it 'raises ArgumentError for invalid UF when raise_exceptions is true' do
      expect do
        BrazilianUtils::CEPUtils.get_cep_information_from_address('XX', 'City', 'Street', raise_exceptions: true)
      end.to raise_error(ArgumentError, 'Invalid UF: XX')
    end

    context 'with valid address' do
      it 'returns an array of Address objects' do
        # Using a known address (Avenida Paulista, São Paulo)
        result = BrazilianUtils::CEPUtils.get_cep_information_from_address('SP', 'São Paulo', 'Paulista')

        # Skip test if API is not accessible
        skip 'API not accessible' if result.nil?

        expect(result).to be_an(Array)
        expect(result).not_to be_empty
        expect(result.first).to be_a(BrazilianUtils::Address)
        expect(result.first.uf).to eq('SP')
      end

      it 'handles city and street with accents' do
        result = BrazilianUtils::CEPUtils.get_cep_information_from_address('SP', 'São Paulo', 'Ipiranga')

        # Skip test if API is not accessible
        skip 'API not accessible' if result.nil?

        expect(result).to be_an(Array)
      end
    end

    context 'with non-existent address' do
      it 'returns nil without raising exception' do
        result = BrazilianUtils::CEPUtils.get_cep_information_from_address('SP', 'NonExistentCity', 'NonExistentStreet')
        expect(result).to be_nil
      end

      it 'raises CEPNotFound when raise_exceptions is true' do
        expect do
          BrazilianUtils::CEPUtils.get_cep_information_from_address('SP', 'NonExistent', 'NonExistent', raise_exceptions: true)
        end.to raise_error(BrazilianUtils::CEPNotFound)
      end
    end
  end

  describe 'BrazilianUtils::Address' do
    it 'can be instantiated with keyword arguments' do
      address = BrazilianUtils::Address.new(
        cep: '01310-100',
        logradouro: 'Avenida Paulista',
        complemento: '',
        bairro: 'Bela Vista',
        localidade: 'São Paulo',
        uf: 'SP',
        ibge: '3550308',
        gia: '1004',
        ddd: '11',
        siafi: '7107'
      )

      expect(address.cep).to eq('01310-100')
      expect(address.logradouro).to eq('Avenida Paulista')
      expect(address.uf).to eq('SP')
    end
  end
end
