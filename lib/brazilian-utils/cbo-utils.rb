require 'json'

module BrazilianUtils
  # Utilities for the CBO (Classificação Brasileira de Ocupações) 2002
  # occupation table (6-digit "ocupação" granularity).
  module CBOUtils
    DATA_FILE = File.join(File.dirname(__FILE__), 'data', 'cbo.json')

    # @private
    def self.load_data
      @data ||= JSON.parse(File.read(DATA_FILE))
    end

    private_class_method :load_data

    # Normalizes a CBO value to its bare 6 digits: bare digits (string or
    # integer) are left-padded with zeros to 6; the `NNNN-NN` mask (a
    # single separator between the groups) is read as written. Any other
    # string is rejected (its digits are not picked out).
    #
    # @private
    def self.normalize(value)
      return nil if value.nil?
      return value.to_s.rjust(6, '0') if value.is_a?(Integer)
      return nil unless value.is_a?(String)

      raw = value.strip
      return raw.rjust(6, '0') if raw.match?(/\A\d+\z/)

      m = raw.match(%r{\A(\d{4})[ .\-/](\d{2})\z})
      m && "#{m[1]}#{m[2]}"
    end

    private_class_method :normalize

    # Checks whether a CBO code exists in the official table.
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

    # Looks a CBO code up and returns its (bare, 6-digit) code and title.
    #
    # @param value [String, Integer]
    # @return [Hash, nil]
    def self.get(value)
      code = normalize(value)
      return nil unless code

      description = load_data[code]
      description && { code: code, description: description }
    end

    # Removes CBO formatting and keeps only digits, capped to 6 digits
    # (nothing is left-padded).
    #
    # @param value [String, Integer]
    # @return [String]
    def self.parse(value)
      return '' unless value.is_a?(String) || value.is_a?(Integer)

      value.to_s.gsub(/\D/, '')[0, 6]
    end
  end
end
