module BrazilianUtils
  module CNPJUtils
    # FORMATTING
    ############

    # Removes specific symbols from a CNPJ (Brazilian Company Registration Number) string.
    #
    # This function takes a CNPJ string as input and removes all occurrences of
    # the '.', '/' and '-' characters from it.
    #
    # @param dirty [String] The CNPJ string containing symbols to be removed.
    # @return [String] A new string with the specified symbols removed.
    #
    # @example
    #   sieve("12.345/6789-01")     #=> "12345678901"
    #   sieve("98/76.543-2101")     #=> "98765432101"
    #
    # @note This method should not be used in new code and is only provided for
    #   backward compatibility. Use {remove_symbols} instead.
    def self.sieve(dirty)
      dirty.to_s.delete('./-')
    end

    # Removes specific symbols from a CNPJ string.
    #
    # This function is an alias for the {sieve} function, offering a more
    # descriptive name.
    #
    # @param dirty [String] The dirty string containing symbols to be removed.
    # @return [String] A new string with the specified symbols removed.
    #
    # @example
    #   remove_symbols("12.345/6789-01")   #=> "12345678901"
    #   remove_symbols("98/76.543-2101")   #=> "98765432101"
    def self.remove_symbols(dirty)
      sieve(dirty)
    end

    # Formats a CNPJ string for visual display (legacy method).
    #
    # Will format an adequately formatted numbers-only CNPJ string,
    # adding in standard formatting visual aid symbols for display.
    #
    # @param cnpj [String] The CNPJ string to be formatted for display.
    # @return [String, nil] The formatted CNPJ with visual aid symbols if it's valid,
    #   nil if it's not valid.
    #
    # @example
    #   display("12345678901234")   #=> "12.345.678/9012-34"
    #   display("98765432100100")   #=> "98.765.432/1001-00"
    #
    # @note This method should not be used in new code and is only provided for
    #   backward compatibility. Use {format_cnpj} instead.
    def self.display(cnpj)
      return nil unless cnpj.to_s.match?(/^\d{14}$/)
      return nil if cnpj.chars.uniq.length == 1

      format('%s.%s.%s/%s-%s',
             cnpj[0..1],
             cnpj[2..4],
             cnpj[5..7],
             cnpj[8..11],
             cnpj[12..13])
    end

    # Formats a CNPJ (Brazilian Company Registration Number) string for visual display.
    #
    # This function takes a CNPJ string as input, validates its format, and
    # formats it with standard visual aid symbols for display purposes.
    #
    # @param cnpj [String] The CNPJ string to be formatted for display.
    # @return [String, nil] The formatted CNPJ with visual aid symbols if it's valid,
    #   nil if it's not valid.
    #
    # @example
    #   format_cnpj("03560714000142")   #=> "03.560.714/0001-42"
    #   format_cnpj("98765432100100")   #=> nil
    def self.format_cnpj(cnpj)
      return nil unless valid?(cnpj)

      format('%s.%s.%s/%s-%s',
             cnpj[0..1],
             cnpj[2..4],
             cnpj[5..7],
             cnpj[8..11],
             cnpj[12..13])
    end

    # OPERATIONS
    ############

    # Validates a CNPJ by comparing its verifying checksum digits to its base number.
    #
    # This function checks the validity of a CNPJ by comparing its verifying
    # checksum digits to its base number. The input should be a string of digits
    # with the appropriate length.
    #
    # @param cnpj [String] The CNPJ to be validated.
    # @return [Boolean] true if the checksum digits match the base number, false otherwise.
    #
    # @example
    #   validate("03560714000142")   #=> true
    #   validate("00111222000133")   #=> false
    #
    # @note This method should not be used in new code and is only provided for
    #   backward compatibility. Use {valid?} instead.
    def self.validate(cnpj)
      return false unless cnpj.to_s.match?(/^\d{14}$/)
      return false if cnpj.chars.uniq.length == 1

      (0..1).all? do |i|
        hashdigit(cnpj, i + 13) == cnpj[12 + i].to_i
      end
    end

    # Returns whether or not the verifying checksum digits of the given CNPJ
    # match its base number.
    #
    # This function does not verify the existence of the CNPJ; it only
    # validates the format of the string.
    #
    # @param cnpj [String] The CNPJ to be validated, a 14-digit string
    # @return [Boolean] true if the checksum digits match the base number, false otherwise.
    #
    # @example
    #   valid?("03560714000142")   #=> true
    #   valid?("00111222000133")   #=> false
    def self.valid?(cnpj)
      cnpj.is_a?(String) && validate(cnpj)
    end

    # Generates a random valid CNPJ digit string.
    #
    # An optional branch number parameter can be given; it defaults to 1.
    #
    # @param branch [Integer] An optional branch number to be included in the CNPJ.
    # @return [String] A randomly generated valid CNPJ string.
    #
    # @example
    #   generate()        #=> "30180536000105"
    #   generate(1234)    #=> "01745284123455"
    def self.generate(branch: 1)
      branch = branch % 10_000
      branch = 1 if branch.zero?
      branch_str = branch.to_s.rjust(4, '0')
      base = format('%08d', rand(100_000_000)) + branch_str

      base + checksum(base)
    end

    # PRIVATE METHODS
    #################

    # Calculates the checksum digit at the given position for the provided CNPJ.
    #
    # The input must contain all elements before position.
    #
    # @param cnpj [String] The CNPJ for which the checksum digit is calculated.
    # @param position [Integer] The position of the checksum digit to be calculated.
    # @return [Integer] The calculated checksum digit.
    #
    # @example
    #   hashdigit("12345678901234", 13)   #=> 3
    #   hashdigit("98765432100100", 14)   #=> 9
    #
    # @private
    def self.hashdigit(cnpj, position)
      # Generate weights: from (position - 8) down to 2, then from 9 down to 2
      weights = []
      (position - 8).downto(2) { |w| weights << w }
      9.downto(2) { |w| weights << w }

      val = cnpj.chars.zip(weights).sum do |digit, weight|
        digit.to_i * weight
      end % 11

      val < 2 ? 0 : 11 - val
    end

    # Calculates the verifying checksum digits for a given CNPJ base number.
    #
    # This function computes the verifying checksum digits for a provided CNPJ
    # base number. The basenum should be a digit-string of the appropriate length.
    #
    # @param basenum [String] The base number of the CNPJ for which verifying
    #   checksum digits are calculated.
    # @return [String] The verifying checksum digits.
    #
    # @example
    #   checksum("123456789012")   #=> "30"
    #   checksum("987654321001")   #=> "41"
    #
    # @private
    def self.checksum(basenum)
      first_digit = hashdigit(basenum, 13).to_s
      second_digit = hashdigit(basenum + first_digit, 14).to_s
      first_digit + second_digit
    end

    private_class_method :hashdigit, :checksum
  end
end
