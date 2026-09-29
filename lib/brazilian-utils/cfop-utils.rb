require 'json'

module BrazilianUtils
  # Utilities for the CFOP (Código Fiscal de Operações e Prestações) table,
  # the consolidated Anexo II of Convênio SINIEF s/nº 1970 in force. Only
  # operable codes are included (group/subgroup headings are excluded).
  module CFOPUtils
    DATA_FILE = File.join(File.dirname(__FILE__), 'data', 'cfop.json')

    # @private
    def self.load_data
      @data ||= JSON.parse(File.read(DATA_FILE))
    end

    private_class_method :load_data

    # Normalizes a CFOP value to its bare 4 digits, honoring the `N.NNN`
    # single-separator mask; returns nil for anything else (nothing is
    # padded, since no CFOP starts with a zero).
    #
    # @private
    def self.normalize(value)
      return nil if value.nil?
      return nil unless value.is_a?(String) || value.is_a?(Integer)

      raw = value.to_s.strip
      return raw if raw.match?(/\A\d{4}\z/)

      m = raw.match(%r{\A(\d)[ .\-/](\d{3})\z})
      m && "#{m[1]}#{m[2]}"
    end

    private_class_method :normalize

    # Checks whether a CFOP code exists in the official table (group and
    # subgroup headings are not operable codes and are rejected).
    #
    # @param value [String, Integer]
    # @return [Boolean]
    def self.is_valid(value)
      code = normalize(value)
      return false unless code

      load_data.key?(code)
    end

    class << self
      alias valid? is_valid
    end

    # Looks a CFOP code up and returns its code and description.
    #
    # @param value [String, Integer]
    # @return [Hash, nil]
    def self.get(value)
      code = normalize(value)
      return nil unless code

      description = load_data[code]
      description && { code: code, description: description }
    end

    # Removes CFOP formatting and keeps only digits, capped to 4 digits
    # (nothing is padded).
    #
    # @param value [String, Integer]
    # @return [String]
    def self.parse(value)
      return '' unless value.is_a?(String) || value.is_a?(Integer)

      value.to_s.gsub(/\D/, '')[0, 4]
    end
  end
end
