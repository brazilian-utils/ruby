require 'json'
require 'net/http'
require 'uri'

module BrazilianUtils
  # Custom exceptions for CEP operations
  class InvalidCEP < StandardError; end
  class CEPNotFound < StandardError; end

  # Brazilian states enum
  module UF
    STATES = {
      'AC' => 'Acre',
      'AL' => 'Alagoas',
      'AP' => 'Amapá',
      'AM' => 'Amazonas',
      'BA' => 'Bahia',
      'CE' => 'Ceará',
      'DF' => 'Distrito Federal',
      'ES' => 'Espírito Santo',
      'GO' => 'Goiás',
      'MA' => 'Maranhão',
      'MT' => 'Mato Grosso',
      'MS' => 'Mato Grosso do Sul',
      'MG' => 'Minas Gerais',
      'PA' => 'Pará',
      'PB' => 'Paraíba',
      'PR' => 'Paraná',
      'PE' => 'Pernambuco',
      'PI' => 'Piauí',
      'RJ' => 'Rio de Janeiro',
      'RN' => 'Rio Grande do Norte',
      'RS' => 'Rio Grande do Sul',
      'RO' => 'Rondônia',
      'RR' => 'Roraima',
      'SC' => 'Santa Catarina',
      'SP' => 'São Paulo',
      'SE' => 'Sergipe',
      'TO' => 'Tocantins'
    }.freeze

    def self.valid?(uf)
      STATES.key?(uf.to_s.upcase)
    end

    def self.name_from_code(code)
      STATES[code.to_s.upcase]
    end

    def self.code_from_name(name)
      STATES.key(name)
    end
  end

  # Address structure
  Address = Struct.new(
    :cep,
    :logradouro,
    :complemento,
    :bairro,
    :localidade,
    :uf,
    :ibge,
    :gia,
    :ddd,
    :siafi,
    keyword_init: true
  )

  module CEPUtils
    # FORMATTING
    ############

    # Removes specific symbols from a given CEP (Postal Code).
    #
    # This function takes a CEP (Postal Code) as input and removes all occurrences
    # of the '.' and '-' characters from it.
    #
    # @param dirty [String] The input CEP (Postal Code) containing symbols to be removed.
    # @return [String] A new string with the specified symbols removed.
    #
    # @example
    #   remove_symbols("123-45.678.9")  #=> "123456789"
    #   remove_symbols("abc.xyz")       #=> "abcxyz"
    def self.remove_symbols(dirty)
      return '' unless dirty

      dirty.to_s.delete('.-')
    end

    # Formats a Brazilian CEP (Postal Code) into a standard format.
    #
    # This function takes a CEP (Postal Code) as input and, if it is a valid
    # 8-digit CEP, formats it into the standard "12345-678" format.
    #
    # @param cep [String] The input CEP (Postal Code) to be formatted.
    # @return [String, nil] The formatted CEP in the "12345-678" format if it's valid,
    #   nil if it's not valid.
    #
    # @example
    #   format_cep("12345678")  #=> "12345-678"
    #   format_cep("12345")     #=> nil
    def self.format_cep(cep)
      return nil unless valid?(cep)

      "#{cep[0..4]}-#{cep[5..7]}"
    end

    # OPERATIONS
    ############

    # Checks if a CEP (Postal Code) is valid.
    #
    # To be considered valid, the input must be a string containing exactly 8
    # digits.
    # This function does not verify if the CEP is a real postal code; it only
    # validates the format of the string.
    #
    # @param cep [String] The string containing the CEP to be checked.
    # @return [Boolean] true if the CEP is valid (8 digits), false otherwise.
    #
    # @example
    #   valid?("12345678")  #=> true
    #   valid?("12345")     #=> false
    #   valid?("abcdefgh")  #=> false
    #
    # @see https://en.wikipedia.org/wiki/Código_de_Endereçamento_Postal
    def self.valid?(cep)
      return false unless cep.is_a?(String)

      cep.length == 8 && cep.match?(/^\d{8}$/)
    end

    # Generates a random 8-digit CEP (Postal Code) number as a string.
    #
    # @return [String] A randomly generated 8-digit number.
    #
    # @example
    #   generate()  #=> "12345678"
    def self.generate
      8.times.map { rand(10) }.join
    end

    # API OPERATIONS
    ################

    # Fetches address information from a given CEP (Postal Code) using the ViaCEP API.
    #
    # @param cep [String] The CEP (Postal Code) to be used in the search.
    # @param raise_exceptions [Boolean] Whether to raise exceptions when the CEP
    #   is invalid or not found. Defaults to false.
    #
    # @raise [InvalidCEP] When the input CEP is invalid.
    # @raise [CEPNotFound] When the input CEP is not found.
    #
    # @return [Address, nil] An Address object containing the address information
    #   if the CEP is found, nil otherwise.
    #
    # @example
    #   get_address_from_cep("01310100")
    #   #=> #<Address cep="01310-100", logradouro="Avenida Paulista", ...>
    #
    #   get_address_from_cep("abcdefg")  #=> nil
    #
    #   get_address_from_cep("abcdefg", true)
    #   #=> InvalidCEP: CEP 'abcdefg' is invalid.
    #
    #   get_address_from_cep("00000000", true)
    #   #=> CEPNotFound: 00000000
    #
    # @see https://viacep.com.br/
    def self.get_address_from_cep(cep, raise_exceptions: false)
      base_api_url = 'https://viacep.com.br/ws/%s/json/'

      clean_cep = remove_symbols(cep)
      cep_is_valid = valid?(clean_cep)

      unless cep_is_valid
        raise InvalidCEP, "CEP '#{cep}' is invalid." if raise_exceptions

        return nil
      end

      begin
        uri = URI.parse(format(base_api_url, clean_cep))
        response = Net::HTTP.get_response(uri)

        unless response.is_a?(Net::HTTPSuccess)
          raise CEPNotFound, cep if raise_exceptions

          return nil
        end

        data = JSON.parse(response.body)

        if data['erro']
          raise CEPNotFound, cep if raise_exceptions

          return nil
        end

        Address.new(
          cep: data['cep'],
          logradouro: data['logradouro'],
          complemento: data['complemento'],
          bairro: data['bairro'],
          localidade: data['localidade'],
          uf: data['uf'],
          ibge: data['ibge'],
          gia: data['gia'],
          ddd: data['ddd'],
          siafi: data['siafi']
        )
      rescue StandardError => e
        raise CEPNotFound, cep if raise_exceptions

        nil
      end
    end

    # Fetches CEP (Postal Code) options from a given address using the ViaCEP API.
    #
    # @param federal_unit [String] The two-letter abbreviation of the Brazilian state.
    # @param city [String] The name of the city.
    # @param street [String] The name (or substring) of the street.
    # @param raise_exceptions [Boolean] Whether to raise exceptions when the address
    #   is invalid or not found. Defaults to false.
    #
    # @raise [ArgumentError] When the input UF is invalid.
    # @raise [CEPNotFound] When the input address is not found.
    #
    # @return [Array<Address>, nil] An array of Address objects containing the address
    #   information if the address is found, nil otherwise.
    #
    # @example
    #   get_cep_information_from_address("SP", "São Paulo", "Avenida Paulista")
    #   #=> [#<Address cep="01310-100", logradouro="Avenida Paulista", ...>, ...]
    #
    #   get_cep_information_from_address("A", "Example", "Rua Example")  #=> nil
    #
    #   get_cep_information_from_address("XX", "Example", "Example", true)
    #   #=> ArgumentError: Invalid UF: XX
    #
    #   get_cep_information_from_address("SP", "Example", "Example", true)
    #   #=> CEPNotFound: SP - Example - Example
    #
    # @see https://viacep.com.br/
    def self.get_cep_information_from_address(federal_unit, city, street, raise_exceptions: false)
      base_api_url = 'https://viacep.com.br/ws/%s/%s/%s/json/'

      # Validate UF
      uf_code = federal_unit.to_s.upcase
      uf_name = UF.name_from_code(uf_code)

      unless uf_name || UF.code_from_name(federal_unit)
        if raise_exceptions
          raise ArgumentError, "Invalid UF: #{federal_unit}"
        end

        return nil
      end

      # Use state name if code was provided
      uf_to_use = uf_name ? federal_unit : UF.code_from_name(federal_unit)

      # Normalize and encode city and street (remove accents and encode spaces)
      parsed_city = normalize_string(city)
      parsed_street = normalize_string(street)

      begin
        uri = URI.parse(format(base_api_url, uf_to_use, parsed_city, parsed_street))
        response = Net::HTTP.get_response(uri)

        unless response.is_a?(Net::HTTPSuccess)
          if raise_exceptions
            raise CEPNotFound, "#{federal_unit} - #{city} - #{street}"
          end

          return nil
        end

        data = JSON.parse(response.body)

        if data.empty?
          if raise_exceptions
            raise CEPNotFound, "#{federal_unit} - #{city} - #{street}"
          end

          return nil
        end

        data.map do |address_data|
          Address.new(
            cep: address_data['cep'],
            logradouro: address_data['logradouro'],
            complemento: address_data['complemento'],
            bairro: address_data['bairro'],
            localidade: address_data['localidade'],
            uf: address_data['uf'],
            ibge: address_data['ibge'],
            gia: address_data['gia'],
            ddd: address_data['ddd'],
            siafi: address_data['siafi']
          )
        end
      rescue JSON::ParserError, StandardError => e
        if raise_exceptions
          raise CEPNotFound, "#{federal_unit} - #{city} - #{street}"
        end

        nil
      end
    end

    private

    # Normalizes a string by removing accents and encoding spaces for URL
    def self.normalize_string(str)
      require 'unicode_normalize/normalize'

      str.to_s
         .unicode_normalize(:nfd)
         .encode('ASCII', undef: :replace, replace: '')
         .gsub(' ', '%20')
    rescue StandardError
      # Fallback if unicode_normalize is not available
      str.to_s.gsub(' ', '%20')
    end
  end
end
