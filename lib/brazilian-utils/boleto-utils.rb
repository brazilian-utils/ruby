# frozen_string_literal: true

module BrazilianUtils
  module BoletoUtils
    # Every Digitable Line from Boleto has exactly 47 characters
    DIGITABLE_LINE_LENGTH = 47

    # Positions to convert digitable line to boleto
    DIGITABLE_LINE_TO_BOLETO_CONVERT_POSITIONS = [
      { start: 0, end: 4 },
      { start: 32, end: 47 },
      { start: 4, end: 9 },
      { start: 10, end: 20 },
      { start: 21, end: 31 }
    ].freeze

    # Partials to verify with mod10
    PARTIALS_TO_VERIFY_MOD10 = [
      { start: 0, end: 9, digit_index: 9 },
      { start: 10, end: 20, digit_index: 20 },
      { start: 21, end: 31, digit_index: 31 }
    ].freeze

    # Mod10 weights
    MOD10_WEIGHTS = [2, 1].freeze

    # Check digit mod11 position
    CHECK_DIGIT_MOD11_POSITION = 4

    # Mod11 weights configuration
    MOD11_WEIGHTS = {
      initial: 2,
      end: 9,
      increment: 1
    }.freeze

    class << self
      # Validates if a given Digitable Line is valid.
      #
      # @param digitable_line [String] The boleto digitable line to validate
      # @return [Boolean] true if valid, false otherwise
      def is_valid(digitable_line)
        # Extract only numbers from the input
        digitable_line_numbers = extract_only_numbers(digitable_line)

        return false unless valid_length?(digitable_line_numbers)
        return false unless validate_digitable_line_partials(digitable_line_numbers)

        validate_mod11_check_digit(digitable_line_numbers)
      end

      # Alias for is_valid
      alias valid? is_valid

      private

      # Extract only numeric characters from a string.
      #
      # @param str [String] The input string
      # @return [String] String containing only numeric characters
      def extract_only_numbers(str)
        return '' if str.nil?

        str.gsub(/\D/, '')
      end

      # Validates the string length.
      #
      # @param digitable_line [String] The digitable line to check
      # @return [Boolean] true if length is exactly 47, false otherwise
      def valid_length?(digitable_line)
        digitable_line.length == DIGITABLE_LINE_LENGTH
      end

      # Validates the digitable line partials using mod10.
      #
      # @param digitable_line [String] The digitable line to validate
      # @return [Boolean] true if all partials are valid, false otherwise
      def validate_digitable_line_partials(digitable_line)
        PARTIALS_TO_VERIFY_MOD10.all? do |partial|
          partial_str = digitable_line[partial[:start]...partial[:end]]
          mod10 = get_mod10(partial_str)
          digit = digitable_line[partial[:digit_index]].to_i
          digit == mod10
        end
      end

      # Calculate mod10 for a given partial string.
      #
      # @param partial [String] The partial string to calculate mod10 for
      # @return [Integer] The mod10 check digit
      def get_mod10(partial)
        sum = 0
        partial_reversed = partial.reverse

        partial_reversed.each_char.with_index do |char, index|
          partial_value = char.to_i
          weight = MOD10_WEIGHTS[index % 2]
          multiplier = partial_value * weight

          if multiplier > 9
            sum += 1 + (multiplier % 10)
          else
            sum += multiplier
          end
        end

        mod10 = sum % 10
        if mod10 > 0
          10 - mod10
        else
          0
        end
      end

      # Validates the mod11 check digit.
      #
      # @param digitable_line [String] The digitable line to validate
      # @return [Boolean] true if mod11 check digit is valid, false otherwise
      def validate_mod11_check_digit(digitable_line)
        parsed_digitable_line = parse_digitable_line(digitable_line)
        
        # Extract the value before and after the check digit position
        value = parsed_digitable_line[0...CHECK_DIGIT_MOD11_POSITION] +
                parsed_digitable_line[(CHECK_DIGIT_MOD11_POSITION + 1)..-1]
        
        mod11 = get_mod11(value)
        mod11_value = parsed_digitable_line[CHECK_DIGIT_MOD11_POSITION].to_i

        mod11_value == mod11
      end

      # Parse the digitable line by extracting specific positions.
      #
      # @param digitable_line [String] The digitable line to parse
      # @return [String] The parsed digitable line
      def parse_digitable_line(digitable_line)
        result = ''
        DIGITABLE_LINE_TO_BOLETO_CONVERT_POSITIONS.each do |position|
          result += digitable_line[position[:start]...position[:end]]
        end
        result
      end

      # Calculate mod11 for a given value string.
      #
      # @param value [String] The value string to calculate mod11 for
      # @return [Integer] The mod11 check digit
      def get_mod11(value)
        weight = MOD11_WEIGHTS[:initial]
        sum = 0
        value_reversed = value.reverse

        value_reversed.each_char do |char|
          value_value = char.to_i
          multiplier = value_value * weight

          if weight < MOD11_WEIGHTS[:end]
            weight += MOD11_WEIGHTS[:increment]
          else
            weight = MOD11_WEIGHTS[:initial]
          end

          sum += multiplier
        end

        mod11 = sum % 11
        if mod11 != 0 && mod11 != 1
          11 - mod11
        else
          1
        end
      end
    end
  end
end
