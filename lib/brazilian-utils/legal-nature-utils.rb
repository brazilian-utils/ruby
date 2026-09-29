require 'json'

module BrazilianUtils
  # Utilities for consulting and validating the official *Natureza Jurídica* (Legal Nature)
  # codes defined by IBGE/CONCLA and the Receita Federal do Brasil (RFB).
  #
  # The table backing this module is CONCLA's Natureza Jurídica 2021 table:
  # 92 codes currently in force, plus a best-effort list of codes retired by
  # past revisions (see `data/legal_nature.json`).
  #
  # This module offers simple lookups and validation helpers based on the
  # official table. It does not infer the current legal/registration status
  # of any entity.
  #
  # Source: https://concla.ibge.gov.br/images/concla/documentacao/CONCLA-TNJ2021-NotasExplicativas.pdf
  module LegalNatureUtils
    DATA_FILE = File.join(File.dirname(__FILE__), 'data', 'legal_nature.json')

    # @private
    def self.load_data
      return @data if @data

      raw = JSON.parse(File.read(DATA_FILE))
      in_force = {}
      raw['inForce'].each { |row| in_force[row['code']] = row }
      retired = {}
      raw['retired'].each { |row| retired[row['code']] = row }
      @data = { in_force: in_force, retired: retired }
    end

    private_class_method :load_data

    # Normalizes a legal nature code: strips hyphens, dots and whitespace,
    # and requires exactly 4 digits.
    #
    # @param code [String, Integer] The code to normalize
    # @return [String, nil] The normalized 4-digit code, or nil if invalid
    #
    # @private
    def self.normalize(code)
      return nil unless code.is_a?(String) || code.is_a?(Integer)

      digits = code.to_s.gsub(/[-.\s]/, '')
      digits.match?(/\A\d{4}\z/) ? digits : nil
    end

    private_class_method :normalize

    # @private
    def self.entry_to_hash(row)
      entry = {
        code: row['code'],
        description: row['description'],
        category: { code: row['category']['code'], description: row['category']['description'] },
        legacy: row['legacy']
      }
      entry[:currentCode] = row['currentCode'] if row['legacy']
      entry
    end

    private_class_method :entry_to_hash

    # Checks if a string corresponds to a valid *Natureza Jurídica* code.
    #
    # Accepts both the 92 codes currently in force and the (best-effort)
    # list of codes retired by a past revision.
    #
    # @param code [String] The code to be validated. Accepts "NNNN" or
    #   "NNN-N", with hyphens/dots/whitespace tolerated around the digits.
    #
    # @return [Boolean] Returns true if the normalized code exists in the
    #   official table (in force or retired), false otherwise.
    #
    # @example Valid codes
    #   is_valid("2062")      #=> true (Sociedade Empresária Limitada)
    #   is_valid("206-2")     #=> true (same, with hyphen)
    #
    # @example Invalid codes
    #   is_valid("9999")      #=> false (not in official table)
    #   is_valid("abcd")      #=> false (not digits)
    #   is_valid(nil)         #=> false (not a string)
    def self.is_valid(code)
      normalized = normalize(code)
      return false unless normalized

      data = load_data
      data[:in_force].key?(normalized) || data[:retired].key?(normalized)
    end

    class << self
      alias valid? is_valid
    end

    # Retrieves the description of a *Natureza Jurídica* code.
    #
    # @param code [String] The code to look up. Accepts "NNNN" or "NNN-N".
    #
    # @return [String, nil] The full description if the code is valid, otherwise nil.
    #
    # @example
    #   get_description("2062")   #=> "Sociedade Empresária Limitada"
    #   get_description("101-5")  #=> "Órgão Público do Poder Executivo Federal"
    def self.get_description(code)
      normalized = normalize(code)
      return nil unless normalized

      data = load_data
      row = data[:in_force][normalized] || data[:retired][normalized]
      row && row['description']
    end

    # Looks a legal nature code up in the IBGE/CONCLA Natureza Jurídica 2021
    # table.
    #
    # @param value [String, Integer] The code to look up ("NNNN" or "NNN-N").
    # @return [Hash, nil] `{ code:, description:, category: { code:,
    #   description: }, legacy:, currentCode: (only when legacy) }`, or nil
    #   for an unknown code.
    #
    # @example
    #   get("2062")   #=> { code: "2062", description: "Sociedade Empresária Limitada", category: { code: "2", description: "Entidades Empresariais" }, legacy: false }
    #   get("2208")   #=> { code: "2208", description: "Entidade Binacional Itaipu", ..., legacy: true, currentCode: "2275" }
    def self.get(value)
      normalized = normalize(value)
      return nil unless normalized

      data = load_data
      row = data[:in_force][normalized] || data[:retired][normalized]
      row && entry_to_hash(row)
    end

    # Formats a legal nature code as `NNN-N`.
    #
    # The mask is applied as far as the digits go (fewer than 4 digits are
    # returned unmasked); use {is_valid} to check the code first.
    #
    # @param value [String, Integer] The value to format.
    # @param options [Hash] `:pad` left-pads the value with zeros to 4
    #   digits first.
    # @return [String] The masked code, or as much of the mask as fits.
    #
    # @example
    #   format("2062")           #=> "206-2"
    #   format("206-2")          #=> "206-2"
    #   format("206")            #=> "206"
    def self.format(value, options = {})
      digits = value.to_s.gsub(/\D/, '')
      digits = digits.rjust(4, '0') if options[:pad] || options['pad']
      return digits if digits.length < 4

      "#{digits[0, 3]}-#{digits[3]}"
    end

    # Generates a random valid legal nature code (4 digits), drawn only
    # among the 92 codes currently in force.
    #
    # @return [String] A randomly generated, valid legal nature code.
    def self.generate
      load_data[:in_force].keys.sample
    end

    # Returns a copy of the *Natureza Jurídica* table as a map from code to
    # description.
    #
    # @param params [Hash] `:include_retired` also includes the retired
    #   codes (default false: only the 92 codes in force).
    # @return [Hash<String, String>] Mapping from 4-digit codes to descriptions
    #
    # @example
    #   all_codes = list
    #   all_codes["2062"]  #=> "Sociedade Empresária Limitada"
    def self.list(params = {})
      include_retired = params[:include_retired] || params['include_retired']
      data = load_data
      result = {}
      data[:in_force].each { |code, row| result[code] = row['description'] }
      data[:retired].each { |code, row| result[code] = row['description'] } if include_retired
      result
    end

    class << self
      alias list_all list
    end

    # Returns every legal nature of a CONCLA category (the first digit of
    # the code), sorted by code.
    #
    # Categories: 1 Administração Pública, 2 Entidades Empresariais,
    # 3 Entidades sem Fins Lucrativos, 4 Pessoas Físicas,
    # 5 Organizações Internacionais e Outras Instituições Extraterritoriais.
    #
    # @param category [Integer, String] The category number (1-5)
    # @param options [Hash] `:include_retired` also includes retired codes.
    #
    # @return [Array<Hash>] The legal natures of the category, in the same
    #   shape as {get}, sorted by code; an empty array for an unknown
    #   category.
    def self.list_by_category(category, options = {})
      category_str = category.to_s
      return [] unless %w[1 2 3 4 5].include?(category_str)

      include_retired = options[:include_retired] || options['include_retired']
      data = load_data

      rows = data[:in_force].values.select { |row| row['category']['code'] == category_str }
      rows += data[:retired].values.select { |row| row['category']['code'] == category_str } if include_retired

      rows.sort_by { |row| row['code'] }.map { |row| entry_to_hash(row) }
    end

    # Returns the category number for a given code.
    #
    # @param code [String] The code to check. Accepts "NNNN" or "NNN-N".
    #
    # @return [Integer, nil] The category number (1-5), or nil if invalid
    #
    # @example
    #   get_category("2062")   #=> 2 (Entidades Empresariais)
    #   get_category("9999")   #=> nil (invalid code)
    def self.get_category(code)
      entry = get(code)
      entry && entry[:category][:code].to_i
    end

    # Removes legal nature formatting and keeps only digits, capped to 4 digits.
    #
    # @param value [String, Integer] A legal nature code, with or without formatting.
    # @return [String] The parsed digits.
    #
    # @example
    #   parse("206-2")  #=> "2062"
    def self.parse(value)
      return '' unless value.is_a?(String) || value.is_a?(Integer)

      value.to_s.gsub(/\D/, '')[0, 4]
    end
  end
end
