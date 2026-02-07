module BrazilianUtils
  # Utilities for consulting and validating the official *Natureza Jurídica* (Legal Nature) 
  # codes defined by the Receita Federal do Brasil (RFB).
  #
  # The codes and descriptions in this module are sourced from the official 
  # **Tabela de Natureza Jurídica** (RFB), as provided in the document used 
  # by the Cadastro Nacional (e.g., FCN).
  #
  # This module offers simple lookups and validation helpers based on the official table. 
  # It does not infer the current legal/registration status of any entity.
  #
  # Source: https://www.gov.br/empresas-e-negocios/pt-br/drei/links-e-downloads/arquivos/TABELADENATUREZAJURDICA.pdf
  module LegalNatureUtils
    # Official Legal Nature codes from Receita Federal do Brasil
    # Format: 4-digit code => Description in Portuguese
    LEGAL_NATURE = {
      # 1. ADMINISTRAÇÃO PÚBLICA
      '1015' => 'Órgão Público do Poder Executivo Federal',
      '1023' => 'Órgão Público do Poder Executivo Estadual ou do Distrito Federal',
      '1031' => 'Órgão Público do Poder Executivo Municipal',
      '1040' => 'Órgão Público do Poder Legislativo Federal',
      '1058' => 'Órgão Público do Poder Legislativo Estadual ou do Distrito Federal',
      '1066' => 'Órgão Público do Poder Legislativo Municipal',
      '1074' => 'Órgão Público do Poder Judiciário Federal',
      '1082' => 'Órgão Público do Poder Judiciário Estadual',
      '1104' => 'Autarquia Federal',
      '1112' => 'Autarquia Estadual ou do Distrito Federal',
      '1120' => 'Autarquia Municipal',
      '1139' => 'Fundação Federal',
      '1147' => 'Fundação Estadual ou do Distrito Federal',
      '1155' => 'Fundação Municipal',
      '1163' => 'Órgão Público Autônomo da União',
      '1171' => 'Órgão Público Autônomo Estadual ou do Distrito Federal',
      '1180' => 'Órgão Público Autônomo Municipal',
      
      # 2. ENTIDADES EMPRESARIAIS
      '2011' => 'Empresa Pública',
      '2038' => 'Sociedade de Economia Mista',
      '2046' => 'Sociedade Anônima Aberta',
      '2054' => 'Sociedade Anônima Fechada',
      '2062' => 'Sociedade Empresária Limitada',
      '2070' => 'Sociedade Empresária em Nome Coletivo',
      '2089' => 'Sociedade Empresária em Comandita Simples',
      '2097' => 'Sociedade Empresária em Comandita por Ações',
      '2100' => 'Sociedade Mercantil de Capital e Indústria (extinta pelo NCC/2002)',
      '2127' => 'Sociedade Empresária em Conta de Participação',
      '2135' => 'Empresário (Individual)',
      '2143' => 'Cooperativa',
      '2151' => 'Consórcio de Sociedades',
      '2160' => 'Grupo de Sociedades',
      '2178' => 'Estabelecimento, no Brasil, de Sociedade Estrangeira',
      '2194' => 'Estabelecimento, no Brasil, de Empresa Binacional Argentino-Brasileira',
      '2208' => 'Entidade Binacional Itaipu',
      '2216' => 'Empresa Domiciliada no Exterior',
      '2224' => 'Clube/Fundo de Investimento',
      '2232' => 'Sociedade Simples Pura',
      '2240' => 'Sociedade Simples Limitada',
      '2259' => 'Sociedade em Nome Coletivo',
      '2267' => 'Sociedade em Comandita Simples',
      '2275' => 'Sociedade Simples em Conta de Participação',
      '2305' => 'Empresa Individual de Responsabilidade Limitada',
      
      # 3. ENTIDADES SEM FINS LUCRATIVOS
      '3034' => 'Serviço Notarial e Registral (Cartório)',
      '3042' => 'Organização Social',
      '3050' => 'Organização da Sociedade Civil de Interesse Público (Oscip)',
      '3069' => 'Outras Formas de Fundações Mantidas com Recursos Privados',
      '3077' => 'Serviço Social Autônomo',
      '3085' => 'Condomínio Edilícios',
      '3093' => 'Unidade Executora (Programa Dinheiro Direto na Escola)',
      '3107' => 'Comissão de Conciliação Prévia',
      '3115' => 'Entidade de Mediação e Arbitragem',
      '3123' => 'Partido Político',
      '3131' => 'Entidade Sindical',
      '3204' => 'Estabelecimento, no Brasil, de Fundação ou Associação Estrangeiras',
      '3212' => 'Fundação ou Associação Domiciliada no Exterior',
      '3999' => 'Outras Formas de Associação',
      
      # 4. PESSOAS FÍSICAS
      '4014' => 'Empresa Individual Imobiliária',
      '4022' => 'Segurado Especial',
      '4081' => 'Contribuinte individual',
      
      # 5. ORGANIZAÇÕES INTERNACIONAIS E OUTRAS INSTITUIÇÕES EXTRATERRITORIAIS
      '5002' => 'Organização Internacional e Outras Instituições Extraterritoriais'
    }.freeze

    # Normalizes a legal nature code to 4-digit format.
    # Accepts formats like "2062", "206-2", or any string with exactly 4 digits.
    #
    # @param code [String] The code to normalize
    # @return [String, nil] The normalized 4-digit code, or nil if invalid
    #
    # @private
    def self.normalize(code)
      return nil unless code.is_a?(String)

      # Extract only digits from the input
      digits = code.strip.gsub(/\D/, '')

      # Return the digits only if we have exactly 4
      digits.length == 4 ? digits : nil
    end

    private_class_method :normalize

    # Checks if a string corresponds to a valid *Natureza Jurídica* code.
    #
    # Validation is based solely on the presence of the code in the official RFB table. 
    # It does not verify the current legal status or registration of the entity.
    #
    # @param code [String] The code to be validated. Accepts either "NNNN" or "NNN-N" format.
    #
    # @return [Boolean] Returns true if the normalized code exists in the official table, 
    #   false otherwise.
    #
    # @example Valid codes
    #   is_valid("2062")      #=> true (Sociedade Empresária Limitada)
    #   is_valid("206-2")     #=> true (same, with hyphen)
    #   is_valid("1015")      #=> true (Órgão Público Federal)
    #   is_valid("101-5")     #=> true (same, with hyphen)
    #
    # @example Invalid codes
    #   is_valid("9999")      #=> false (not in official table)
    #   is_valid("0000")      #=> false (not in official table)
    #   is_valid("123")       #=> false (wrong length)
    #   is_valid("abcd")      #=> false (not digits)
    #   is_valid(nil)         #=> false (not a string)
    def self.is_valid(code)
      normalized = normalize(code)
      return false unless normalized

      LEGAL_NATURE.key?(normalized)
    end

    # Alias for is_valid to provide Ruby-style naming
    class << self
      alias valid? is_valid
    end

    # Retrieves the description of a *Natureza Jurídica* code.
    #
    # @param code [String] The code to look up. Accepts either "NNNN" or "NNN-N" format.
    #
    # @return [String, nil] The full description if the code is valid, otherwise nil.
    #
    # @example Valid lookups
    #   get_description("2062")
    #   #=> "Sociedade Empresária Limitada"
    #
    #   get_description("101-5")
    #   #=> "Órgão Público do Poder Executivo Federal"
    #
    #   get_description("2305")
    #   #=> "Empresa Individual de Responsabilidade Limitada"
    #
    # @example Invalid lookups
    #   get_description("0000")
    #   #=> nil
    #
    #   get_description("invalid")
    #   #=> nil
    def self.get_description(code)
      normalized = normalize(code)
      return nil unless normalized

      LEGAL_NATURE[normalized]
    end

    # Returns a copy of the full *Natureza Jurídica* table.
    #
    # @return [Hash<String, String>] Mapping from 4-digit codes to descriptions
    #
    # @example
    #   all_codes = list_all
    #   all_codes["2062"]
    #   #=> "Sociedade Empresária Limitada"
    #
    #   all_codes.size
    #   #=> 64 (total number of codes in the official table)
    def self.list_all
      LEGAL_NATURE.dup
    end

    # Returns all codes within a specific category.
    #
    # Categories:
    # - 1: Administração Pública (Public Administration)
    # - 2: Entidades Empresariais (Business Entities)
    # - 3: Entidades Sem Fins Lucrativos (Non-Profit Entities)
    # - 4: Pessoas Físicas (Individuals)
    # - 5: Organizações Internacionais (International Organizations)
    #
    # @param category [Integer, String] The category number (1-5)
    #
    # @return [Hash<String, String>] Codes and descriptions for the specified category
    #
    # @example
    #   business_entities = list_by_category(2)
    #   business_entities.keys
    #   #=> ["2011", "2038", "2046", ...]
    #
    #   non_profits = list_by_category(3)
    #   non_profits["3123"]
    #   #=> "Partido Político"
    def self.list_by_category(category)
      category_str = category.to_s
      return {} unless ['1', '2', '3', '4', '5'].include?(category_str)

      LEGAL_NATURE.select { |code, _| code.start_with?(category_str) }
    end

    # Returns the category number for a given code.
    #
    # @param code [String] The code to check. Accepts either "NNNN" or "NNN-N" format.
    #
    # @return [Integer, nil] The category number (1-5), or nil if invalid
    #
    # @example
    #   get_category("2062")
    #   #=> 2 (Entidades Empresariais)
    #
    #   get_category("101-5")
    #   #=> 1 (Administração Pública)
    #
    #   get_category("9999")
    #   #=> nil (invalid code)
    def self.get_category(code)
      normalized = normalize(code)
      return nil unless normalized && LEGAL_NATURE.key?(normalized)

      normalized[0].to_i
    end
  end
end
