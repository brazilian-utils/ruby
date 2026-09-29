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
    #   (v1, numeric) or a 14-character alphanumeric string (v2, when
    #   `version: 2` is given).
    # @param version [Integer] `1` (default) validates the classic
    #   all-numeric CNPJ; `2` validates the alphanumeric CNPJ introduced by
    #   IN RFB 2.119.
    # @return [Boolean] true if the checksum digits match the base number, false otherwise.
    #
    # @example
    #   valid?("03560714000142")           #=> true
    #   valid?("00111222000133")           #=> false
    #   valid?("12ABC34501DE35", version: 2)
    def self.valid?(cnpj, version: 1)
      return false unless cnpj.is_a?(String)

      version.to_i == 2 ? valid_v2?(cnpj) : validate(cnpj)
    end

    # Generates a random valid CNPJ digit string.
    #
    # An optional branch number parameter can be given; it defaults to 1
    # (v1) or a random branch 1-9999 (v2, when not given).
    #
    # @param branch [Integer, nil] An optional branch number to be included
    #   in the CNPJ.
    # @param version [Integer] `1` (default) generates the classic
    #   all-numeric CNPJ; `2` generates the alphanumeric CNPJ.
    # @return [String] A randomly generated valid CNPJ string.
    #
    # @example
    #   generate()               #=> "30180536000105"
    #   generate(branch: 1234)   #=> "01745284123455"
    #   generate(version: 2)     #=> "12ABC34501DE35"
    def self.generate(branch: nil, version: 1)
      return generate_v2(branch) if version.to_i == 2

      branch_num = branch.nil? ? 1 : branch % 10_000
      branch_num = 1 if branch_num.zero?
      branch_str = branch_num.to_s.rjust(4, '0')
      base = format('%08d', rand(100_000_000)) + branch_str

      base + checksum(base)
    end

    # V2 (ALPHANUMERIC, IN RFB 2.119)
    #################################

    # Characters usable in the alphanumeric CNPJ's base (positions 0-11).
    V2_CHARSET = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'.freeze

    V2_WEIGHTS_DV1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2].freeze
    V2_WEIGHTS_DV2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2].freeze

    # Maps a base-36 character (`0`-`9`, `A`-`Z`) to its numeric value for
    # the v2 checksum: `'0'`..`'9'` -> 0..9, `'A'`..`'Z'` -> 17..42 (its
    # ASCII code minus 48).
    #
    # @private
    def self.v2_char_value(char)
      char.ord - 48
    end

    private_class_method :v2_char_value

    # Computes a single modulus-11 check digit over `chars` (a String of
    # `0`-`9`/`A`-`Z` characters) using the given per-position weights.
    #
    # @private
    def self.v2_hashdigit(chars, weights)
      sum = chars.chars.each_with_index.sum { |c, i| v2_char_value(c) * weights[i] }
      mod = sum % 11
      mod < 2 ? 0 : 11 - mod
    end

    private_class_method :v2_hashdigit

    # Validates a 14-character alphanumeric CNPJ (case-insensitive).
    #
    # @param cnpj [String]
    # @return [Boolean]
    #
    # @private
    def self.valid_v2?(cnpj)
      upper = cnpj.to_s.upcase
      return false unless upper.match?(/\A[0-9A-Z]{14}\z/)

      dv1 = v2_hashdigit(upper[0, 12], V2_WEIGHTS_DV1)
      return false unless dv1 == v2_char_value(upper[12])

      dv2 = v2_hashdigit(upper[0, 13], V2_WEIGHTS_DV2)
      dv2 == v2_char_value(upper[13])
    end

    private_class_method :valid_v2?

    # Generates a random valid alphanumeric (v2) CNPJ.
    #
    # @param branch [Integer, nil] An optional branch number (1-9999); a
    #   random one is used when not given.
    # @return [String]
    #
    # @private
    def self.generate_v2(branch = nil)
      branch_num = branch.nil? ? rand(1..9999) : branch % 10_000
      branch_num = 1 if branch_num.zero?
      branch_str = branch_num.to_s.rjust(4, '0')

      base8 = Array.new(8) { V2_CHARSET[rand(V2_CHARSET.length)] }.join
      base12 = base8 + branch_str

      dv1 = v2_hashdigit(base12, V2_WEIGHTS_DV1)
      dv2 = v2_hashdigit(base12 + dv1.to_s, V2_WEIGHTS_DV2)

      "#{base12}#{dv1}#{dv2}"
    end

    private_class_method :generate_v2

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

      val = cnpj.chars.first(position - 1).zip(weights).sum do |digit, weight|
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

    # Removes CNPJ formatting and returns the normalized value, capped to 14
    # characters.
    #
    # @param value [String, Integer] A CNPJ, with or without formatting.
    # @param options [Hash] `:version` `1` (default) keeps digits only; `2`
    #   keeps letters and digits, upper-cased (the alphanumeric CNPJ format).
    # @return [String] The parsed value.
    #
    # @example
    #   parse("46.843.485/0001-86")  #=> "46843485000186"
    def self.parse(value, options = {})
      return '' unless value.is_a?(String) || value.is_a?(Integer)

      version = (options[:version] || options['version'] || 1).to_i

      cleaned = if version == 2
                  value.to_s.gsub(/[^a-zA-Z0-9]/, '').upcase
                else
                  value.to_s.gsub(/\D/, '')
                end

      cleaned[0, 14]
    end
  end
end
