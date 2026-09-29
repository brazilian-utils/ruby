module BrazilianUtils
  # Utilities for validating a VIN (chassi) structurally: 17 characters,
  # none of the excluded letters `I`, `O`, `Q`, and the check digit at
  # position 9 (the North American / ISO 3779 rule).
  #
  # Brazilian rules do not mandate the check digit, so many Brazilian-built
  # VINs fail it; this validates structure only, as the contract does.
  module VINUtils
    TRANSLITERATION = {
      'A' => 1, 'B' => 2, 'C' => 3, 'D' => 4, 'E' => 5, 'F' => 6, 'G' => 7, 'H' => 8,
      'J' => 1, 'K' => 2, 'L' => 3, 'M' => 4, 'N' => 5, 'P' => 7, 'R' => 9,
      'S' => 2, 'T' => 3, 'U' => 4, 'V' => 5, 'W' => 6, 'X' => 7, 'Y' => 8, 'Z' => 9
    }.freeze

    WEIGHTS = [8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2].freeze

    EXCLUDED_LETTERS = %w[I O Q].freeze

    # Validates a VIN structurally.
    #
    # @param value [String] Case-insensitive.
    # @return [Boolean]
    def self.is_valid(value)
      return false unless value.is_a?(String)

      vin = value.strip.upcase
      return false unless vin.length == 17
      return false unless vin.match?(/\A[A-Z0-9]{17}\z/)
      return false if EXCLUDED_LETTERS.any? { |l| vin.include?(l) }
      return false if vin.chars.uniq.length == 1

      values = vin.chars.map { |c| c.match?(/\d/) ? c.to_i : TRANSLITERATION[c] }
      return false if values.include?(nil)

      sum = values.each_with_index.sum { |v, i| v * WEIGHTS[i] }
      remainder = sum % 11
      check_char = remainder == 10 ? 'X' : remainder.to_s

      vin[8] == check_char
    end

    class << self
      alias valid? is_valid
    end
  end
end
