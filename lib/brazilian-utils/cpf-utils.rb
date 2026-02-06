module BrazilianUtils
  module CPFUtils
    # FORMATTING
    ############

    # Removes specific symbols from a CPF (Brazilian Individual Taxpayer Number) string.
    #
    # This function takes a CPF string as input and removes all occurrences of
    # the '.', '-' characters from it.
    #
    # @param dirty [String] The CPF string containing symbols to be removed.
    # @return [String] A new string with the specified symbols removed.
    #
    # @example
    #   sieve("123.456.789-01")     #=> "12345678901"
    #   sieve("987-654-321.01")     #=> "98765432101"
    #
    # @note This method should not be used in new code and is only provided for
    #   backward compatibility. Use {remove_symbols} instead.
    def self.sieve(dirty)
      dirty.to_s.delete('.-')
    end

    # Removes specific symbols from a CPF string.
    #
    # This function is an alias for the {sieve} function, offering a more
    # descriptive name.
    #
    # @param dirty [String] The CPF string containing symbols to be removed.
    # @return [String] A new string with the specified symbols removed.
    #
    # @example
    #   remove_symbols("123.456.789-01")   #=> "12345678901"
    #   remove_symbols("987-654-321.01")   #=> "98765432101"
    def self.remove_symbols(dirty)
      sieve(dirty)
    end

    # Formats a CPF for display with visual aid symbols (legacy method).
    #
    # This function takes a numbers-only CPF string as input and adds standard
    # formatting visual aid symbols for display.
    #
    # @param cpf [String] A numbers-only CPF string.
    # @return [String, nil] A formatted CPF string with standard visual aid symbols,
    #   nil if the input is invalid.
    #
    # @example
    #   display("12345678901")   #=> "123.456.789-01"
    #   display("98765432101")   #=> "987.654.321-01"
    #
    # @note This method should not be used in new code and is only provided for
    #   backward compatibility. Use {format_cpf} instead.
    def self.display(cpf)
      return nil unless cpf.to_s.match?(/^\d{11}$/)
      return nil if cpf.chars.uniq.length == 1

      format('%s.%s.%s-%s',
             cpf[0..2],
             cpf[3..5],
             cpf[6..8],
             cpf[9..10])
    end

    # Formats a CPF for display with visual aid symbols.
    #
    # This function takes a numbers-only CPF string as input and adds standard
    # formatting visual aid symbols for display.
    #
    # @param cpf [String] A numbers-only CPF string.
    # @return [String, nil] A formatted CPF string with standard visual aid symbols,
    #   nil if the input is invalid.
    #
    # @example
    #   format_cpf("82178537464")   #=> "821.785.374-64"
    #   format_cpf("55550207753")   #=> "555.502.077-53"
    def self.format_cpf(cpf)
      return nil unless valid?(cpf)

      format('%s.%s.%s-%s',
             cpf[0..2],
             cpf[3..5],
             cpf[6..8],
             cpf[9..10])
    end

    # OPERATIONS
    ############

    # Validates the checksum digits of a CPF.
    #
    # This function checks whether the verifying checksum digits of the given CPF
    # match its base number. The input should be a digit string of the proper length.
    #
    # @param cpf [String] A numbers-only CPF string.
    # @return [Boolean] true if the checksum digits are valid, false otherwise.
    #
    # @example
    #   validate("82178537464")   #=> true
    #   validate("55550207753")   #=> true
    #
    # @note This method should not be used in new code and is only provided for
    #   backward compatibility. Use {valid?} instead.
    def self.validate(cpf)
      return false unless cpf.to_s.match?(/^\d{11}$/)
      return false if cpf.chars.uniq.length == 1

      (0..1).all? do |i|
        hashdigit(cpf, i + 10) == cpf[9 + i].to_i
      end
    end

    # Returns whether or not the verifying checksum digits of the given CPF
    # match its base number.
    #
    # This function does not verify the existence of the CPF; it only
    # validates the format of the string.
    #
    # @param cpf [String] The CPF to be validated, an 11-digit string
    # @return [Boolean] true if the checksum digits match the base number, false otherwise.
    #
    # @example
    #   valid?("82178537464")   #=> true
    #   valid?("55550207753")   #=> true
    #   valid?("00000000000")   #=> false
    #   valid?("123.456.789-01")   #=> false (must be numbers only)
    def self.valid?(cpf)
      cpf.is_a?(String) && validate(cpf)
    end

    # Generates a random valid CPF digit string.
    #
    # This function generates a random valid CPF string.
    #
    # @return [String] A random valid CPF string.
    #
    # @example
    #   generate()   #=> "10895948109"
    #   generate()   #=> "52837606502"
    def self.generate
      base = format('%09d', rand(1..999_999_998))
      base + checksum(base)
    end

    # PRIVATE METHODS
    #################

    # Computes the given position checksum digit for a CPF.
    #
    # This function computes the specified position checksum digit for the CPF input.
    # The input needs to contain all elements previous to the position, or the
    # computation will yield the wrong result.
    #
    # @param cpf [String] A CPF string.
    # @param position [Integer] The position to calculate the checksum digit for.
    # @return [Integer] The calculated checksum digit.
    #
    # @example
    #   hashdigit("52599927765", 11)   #=> 5
    #   hashdigit("52599927765", 10)   #=> 6
    #
    # @private
    def self.hashdigit(cpf, position)
      val = cpf.chars.zip(position.downto(2)).sum do |digit, weight|
        digit.to_i * weight
      end % 11

      val < 2 ? 0 : 11 - val
    end

    # Computes the checksum digits for a given CPF base number.
    #
    # This function calculates the checksum digits for a given CPF base number.
    # The base number should be a digit string of adequate length.
    #
    # @param basenum [String] A digit string of adequate length (9 digits).
    # @return [String] The calculated checksum digits (2 digits).
    #
    # @example
    #   checksum("335451269")   #=> "51"
    #   checksum("382916331")   #=> "26"
    #
    # @private
    def self.checksum(basenum)
      first_digit = hashdigit(basenum, 10).to_s
      second_digit = hashdigit(basenum + first_digit, 11).to_s
      first_digit + second_digit
    end

    private_class_method :hashdigit, :checksum
  end
end
