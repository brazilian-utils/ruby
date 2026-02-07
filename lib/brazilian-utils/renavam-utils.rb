module BrazilianUtils
  # Utilities for validating Brazilian RENAVAM numbers.
  #
  # RENAVAM (Registro Nacional de Veículos Automotores) is an 11-digit
  # identification number for motor vehicles in Brazil.
  #
  # The last digit is a verification digit calculated from the first 10 digits.
  module RENAVAMUtils
    # Weights used for verification digit calculation
    # Applied to the first 10 digits in reverse order
    DV_WEIGHTS = [2, 3, 4, 5, 6, 7, 8, 9, 2, 3].freeze

    # Validates the Brazilian vehicle registration number (RENAVAM).
    #
    # This function takes a RENAVAM string and checks if it is valid.
    # A valid RENAVAM consists of exactly 11 digits, with the last digit as
    # a verification digit calculated from the previous 10 digits.
    #
    # @param renavam [String] The RENAVAM string to be validated
    #
    # @return [Boolean] True if the RENAVAM is valid, false otherwise
    #
    # @example
    #   is_valid_renavam("86769597308")
    #   #=> true
    #
    #   is_valid_renavam("12345678901")
    #   #=> false
    #
    #   is_valid_renavam("1234567890a")
    #   #=> false (contains letter)
    #
    #   is_valid_renavam("12345678 901")
    #   #=> false (contains space)
    #
    #   is_valid_renavam("12345678")
    #   #=> false (wrong length)
    #
    #   is_valid_renavam("")
    #   #=> false
    def self.is_valid_renavam(renavam)
      return false unless validate_renavam_format(renavam)

      calculate_renavam_dv(renavam) == renavam[-1].to_i
    end

    # Alias for is_valid_renavam
    class << self
      alias is_valid is_valid_renavam
      alias valid? is_valid_renavam
    end

    # Validates the format of a RENAVAM string.
    #
    # Checks:
    # - Must be a string
    # - Must be exactly 11 digits
    # - Cannot be all the same digit (e.g., "11111111111")
    #
    # @param renavam [String] The RENAVAM string to validate
    #
    # @return [Boolean] True if format is valid, false otherwise
    #
    # @private
    def self.validate_renavam_format(renavam)
      return false unless renavam.is_a?(String)
      return false unless renavam.length == 11
      return false unless renavam.match?(/^\d+$/)
      return false if renavam.chars.uniq.length == 1  # All same digit

      true
    end

    private_class_method :validate_renavam_format

    # Sums the weighted digits of a RENAVAM.
    #
    # Takes the first 10 digits, reverses them, multiplies each by the
    # corresponding weight, and returns the sum.
    #
    # @param renavam [String] The RENAVAM string
    #
    # @return [Integer] The sum of weighted digits
    #
    # @private
    def self.sum_weighted_digits(renavam)
      base_digits = renavam[0..9].reverse.chars.map(&:to_i)
      base_digits.zip(DV_WEIGHTS).sum { |digit, weight| digit * weight }
    end

    private_class_method :sum_weighted_digits

    # Calculates the verification digit for a RENAVAM.
    #
    # Algorithm:
    # 1. Sum the weighted digits (first 10 digits reversed, multiplied by weights)
    # 2. Calculate: 11 - (sum % 11)
    # 3. If result >= 10, return 0, otherwise return the result
    #
    # @param renavam [String] The RENAVAM string
    #
    # @return [Integer] The verification digit (0-9)
    #
    # @private
    def self.calculate_renavam_dv(renavam)
      weighted_sum = sum_weighted_digits(renavam)
      dv = 11 - (weighted_sum % 11)
      dv >= 10 ? 0 : dv
    end

    private_class_method :calculate_renavam_dv
  end
end
