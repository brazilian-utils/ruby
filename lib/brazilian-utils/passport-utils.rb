module BrazilianUtils
  # Utilities for formatting, validating and generating Brazilian passport
  # numbers: 2 letters followed by 6 digits. There is no check digit.
  module PassportUtils
    # Removes the formatting symbols (`-`, `.`, `/` and whitespace),
    # keeping everything else.
    #
    # @param value [String]
    # @return [String]
    def self.remove_symbols(value)
      return '' unless value.is_a?(String)

      value.gsub(%r{[-./\s]}, '')
    end

    # Removes every non-alphanumeric character from a passport number,
    # upper-cases it and caps it to 8 characters.
    #
    # @param value [String]
    # @return [String]
    #
    # @example
    #   parse("Ab123456")     #=> "AB123456"
    #   parse(" AB 123 456 ") #=> "AB123456"
    def self.parse(value)
      return '' unless value.is_a?(String)

      value.gsub(/[^a-zA-Z0-9]/, '').upcase[0, 8]
    end

    # Formats a passport number: the same operation as {parse}.
    #
    # @param value [String]
    # @return [String]
    def self.format(value)
      parse(value)
    end

    # Validates a Brazilian passport number: 2 letters followed by 6
    # digits, after removing non-alphanumeric characters.
    #
    # @param value [String, Integer]
    # @return [Boolean]
    def self.is_valid(value)
      return false unless value.is_a?(String) || value.is_a?(Integer)

      cleaned = value.to_s.gsub(/[^a-zA-Z0-9]/, '')
      cleaned.match?(/\A[A-Za-z]{2}\d{6}\z/)
    end

    class << self
      alias valid? is_valid
    end

    # Generates a random valid passport number: 2 uppercase letters
    # followed by 6 digits.
    #
    # @return [String]
    def self.generate
      letters = 2.times.map { ('A'..'Z').to_a.sample }.join
      digits = 6.times.map { rand(0..9) }.join
      "#{letters}#{digits}"
    end
  end
end
