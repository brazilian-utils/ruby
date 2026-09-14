module BrazilianUtils
  module CNHUtils
    # Validates the registration number for the Brazilian CNH (Carteira Nacional de Habilitação)
    # that was created in 2022.
    #
    # Previous versions of the CNH are not supported in this version.
    # This function checks if the given CNH is valid based on the format and allowed characters,
    # verifying the verification digits.
    #
    # @param cnh [String] CNH string (symbols will be ignored).
    # @return [Boolean] true if CNH has a valid format, false otherwise.
    #
    # @example
    #   valid?("12345678901")      #=> false
    #   valid?("A2C45678901")      #=> false
    #   valid?("98765432100")      #=> true
    #   valid?("987654321-00")     #=> true
    def self.valid?(cnh)
      return false unless cnh

      # Clean the input and check for numbers only
      clean_cnh = cnh.to_s.gsub(/\D/, '')

      return false if clean_cnh.empty?
      return false if clean_cnh.length != 11

      # Reject sequences as "00000000000", "11111111111", etc.
      return false if clean_cnh == clean_cnh[0] * 11

      # Cast digits to array of integers
      digits = clean_cnh.chars.map(&:to_i)
      first_verificator = digits[9]
      second_verificator = digits[10]

      # Check the 10th digit; keep the raw remainder (0-10), since the
      # decrement applied to the 11th digit depends on whether the *pre-cap*
      # remainder overflowed (>9), not on the printed digit (always 0-9).
      first_rest = calculate_first_rest(digits)
      expected_first = first_rest > 9 ? 0 : first_rest
      return false unless expected_first == first_verificator

      # Check the 11th digit
      check_second_verificator(digits, second_verificator, first_rest)
    end

    # Computes the raw remainder used to derive the CNH's first verification digit.
    #
    # @param digits [Array<Integer>] Array of CNH digits
    # @return [Integer] The remainder (0-10) before capping to a single printable digit
    #
    # @private
    def self.calculate_first_rest(digits)
      sum = 0
      9.times do |i|
        sum += digits[i] * (9 - i)
      end

      sum % 11
    end

    # Generates the second verification digit and uses it to verify the 11th digit of the CNH
    #
    # @param digits [Array<Integer>] Array of CNH digits
    # @param second_verificator [Integer] The second verification digit (11th digit)
    # @param first_rest [Integer] The raw remainder (0-10) used to compute the 10th digit
    # @return [Boolean] true if the second verificator is valid
    #
    # @private
    def self.check_second_verificator(digits, second_verificator, first_rest)
      sum = 0
      9.times do |i|
        sum += digits[i] * (i + 1)
      end

      result = sum % 11

      if first_rest > 9
        result = (result - 2).negative? ? result + 9 : result - 2
      end

      result = 0 if result > 9

      result == second_verificator
    end

    private_class_method :calculate_first_rest, :check_second_verificator
  end
end
