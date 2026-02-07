module BrazilianUtils
  # Utilities for formatting, validating, and generating Brazilian PIS numbers.
  #
  # PIS (Programa de Integração Social) is an 11-digit identification number
  # for Brazilian workers, similar to a social security number.
  #
  # Format: XXX.XXXXX.XX-X (e.g., "123.45678.90-9")
  module PISUtils
    # Weights used for checksum calculation
    WEIGHTS = [3, 2, 9, 8, 7, 6, 5, 4, 3, 2].freeze

    # Removes formatting symbols from a PIS string.
    #
    # This function takes a PIS string with formatting symbols (dots and hyphens)
    # and returns a cleaned version with only digits.
    #
    # @param pis [String] A PIS string that may contain formatting symbols
    #
    # @return [String] A cleaned PIS string with no formatting symbols
    #
    # @example
    #   remove_symbols("123.45678.90-9")
    #   #=> "12345678909"
    #
    #   remove_symbols("987.65432.10-0")
    #   #=> "98765432100"
    #
    #   remove_symbols("12345678909")
    #   #=> "12345678909"
    def self.remove_symbols(pis)
      return '' unless pis.is_a?(String)
      
      pis.gsub(/[.\-]/, '')
    end

    # Alias for remove_symbols
    class << self
      alias sieve remove_symbols
    end

    # Formats a valid PIS string with standard visual aid symbols.
    #
    # This function takes a valid numbers-only PIS string as input
    # and adds standard formatting visual aid symbols for display.
    #
    # Format: XXX.XXXXX.XX-X
    #
    # @param pis [String] A valid numbers-only PIS string (11 digits)
    #
    # @return [String, nil] A formatted PIS string or nil if invalid
    #
    # @example
    #   format_pis("12345678909")
    #   #=> "123.45678.90-9"
    #
    #   format_pis("98765432100")
    #   #=> "987.65432.10-0"
    #
    #   format_pis("123456789")
    #   #=> nil (invalid)
    def self.format_pis(pis)
      return nil unless is_valid(pis)

      "#{pis[0..2]}.#{pis[3..7]}.#{pis[8..9]}-#{pis[10]}"
    end

    # Alias for format_pis
    class << self
      alias format format_pis
    end

    # Returns whether the verifying checksum digit of the given PIS matches its base number.
    #
    # This function validates that:
    # - The input is a string
    # - The length is exactly 11 digits
    # - All characters are digits
    # - The checksum digit (last digit) is correct
    #
    # @param pis [String] PIS number as a string (11 digits)
    #
    # @return [Boolean] True if PIS is valid, false otherwise
    #
    # @example
    #   is_valid("12345678909")
    #   #=> true
    #
    #   is_valid("123.45678.90-9")
    #   #=> false (contains symbols, use remove_symbols first)
    #
    #   is_valid("12345678900")
    #   #=> false (invalid checksum)
    #
    #   is_valid("123456789")
    #   #=> false (wrong length)
    def self.is_valid(pis)
      return false unless pis.is_a?(String)
      return false unless pis.length == 11
      return false unless pis.match?(/^\d+$/)
      
      pis[-1] == checksum(pis[0..9]).to_s
    end

    # Alias for is_valid
    class << self
      alias valid? is_valid
    end

    # Generates a random valid Brazilian PIS number.
    #
    # This function generates a random PIS number with the following characteristics:
    # - It has 11 digits
    # - It passes the weight calculation check
    #
    # @return [String] A randomly generated valid PIS number as a string
    #
    # @example
    #   generate
    #   #=> "12345678909" (example, actual value is random)
    #
    #   generate
    #   #=> "98765432100" (example)
    def self.generate
      base = rand(0..9_999_999_999).to_s.rjust(10, '0')
      base + checksum(base).to_s
    end

    # Calculates the checksum digit of the given base PIS string.
    #
    # The checksum algorithm:
    # 1. Multiply each of the first 10 digits by corresponding weight
    # 2. Sum all products
    # 3. Calculate: 11 - (sum % 11)
    # 4. If result is 10 or 11, use 0 instead
    #
    # @param base_pis [String] The first 10 digits of a PIS number
    #
    # @return [Integer] The checksum digit (0-9)
    #
    # @private
    def self.checksum(base_pis)
      pis_digits = base_pis.chars.map(&:to_i)
      pis_sum = pis_digits.zip(WEIGHTS).sum { |digit, weight| digit * weight }
      check_digit = 11 - (pis_sum % 11)

      [10, 11].include?(check_digit) ? 0 : check_digit
    end

    private_class_method :checksum
  end
end
