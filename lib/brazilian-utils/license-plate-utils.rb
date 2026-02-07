module BrazilianUtils
  # Utilities for formatting, validating, and generating Brazilian license plates.
  #
  # Brazilian license plates come in two formats:
  # - Old format: LLLNNNN (3 letters + 4 numbers) e.g., "ABC-1234"
  # - Mercosul format: LLLNLNN (3 letters + 1 number + 1 letter + 2 numbers) e.g., "ABC1D23"
  #
  # The Mercosul format was introduced in 2018 as part of a standardization
  # effort across Mercosul countries.
  module LicensePlateUtils
    # Pattern for old format license plates (LLLNNNN)
    OLD_FORMAT_PATTERN = /^[A-Za-z]{3}[0-9]{4}$/.freeze
    
    # Pattern for Mercosul format license plates (LLLNLNN)
    MERCOSUL_PATTERN = /^[A-Z]{3}\d[A-Z]\d{2}$/.freeze

    # Converts an old pattern license plate (LLLNNNN) to Mercosul format (LLLNLNN).
    #
    # The conversion replaces the first digit (position 4) with its corresponding letter
    # (0→A, 1→B, 2→C, ..., 9→J).
    #
    # @param license_plate [String] A string representing the old pattern license plate
    #
    # @return [String, nil] The converted Mercosul license plate (LLLNLNN) or nil if invalid
    #
    # @example
    #   convert_to_mercosul("ABC1234")
    #   #=> "ABC1C34"
    #
    #   convert_to_mercosul("ABC4567")
    #   #=> "ABC4F67"
    #
    #   convert_to_mercosul("ABC-1234")
    #   #=> "ABC1C34"
    #
    #   convert_to_mercosul("ABC4*67")
    #   #=> nil
    def self.convert_to_mercosul(license_plate)
      return nil unless valid_old_format?(license_plate)

      clean = remove_symbols(license_plate).upcase
      chars = clean.chars
      
      # Convert the 5th character (index 4) - the first digit after the letters
      # 0→A, 1→B, 2→C, etc.
      chars[4] = ('A'.ord + chars[4].to_i).chr
      
      chars.join
    end

    # Formats a license plate into the correct pattern.
    #
    # This function receives a license plate in any pattern (LLLNNNN or LLLNLNN)
    # and returns a formatted version:
    # - Old format: adds dash (ABC-1234)
    # - Mercosul format: uppercase without dash (ABC1D34)
    #
    # @param license_plate [String] A license plate string
    #
    # @return [String, nil] The formatted license plate string or nil if invalid
    #
    # @example
    #   format_license_plate("ABC1234")
    #   #=> "ABC-1234" (old format with dash)
    #
    #   format_license_plate("abc1e34")
    #   #=> "ABC1E34" (Mercosul format, uppercase)
    #
    #   format_license_plate("ABC-1234")
    #   #=> "ABC-1234" (already formatted old format)
    #
    #   format_license_plate("ABC123")
    #   #=> nil (invalid)
    def self.format_license_plate(license_plate)
      return nil unless license_plate.is_a?(String)

      clean = remove_symbols(license_plate).upcase

      if valid_old_format?(clean)
        # Old format: add dash after 3rd character
        "#{clean[0..2]}-#{clean[3..-1]}"
      elsif valid_mercosul?(clean)
        # Mercosul format: just uppercase, no dash
        clean
      else
        nil
      end
    end

    # Alias for format_license_plate
    class << self
      alias format format_license_plate
    end

    # Returns if a Brazilian license plate number is valid.
    #
    # It does not verify if the plate actually exists, only validates the format.
    #
    # @param license_plate [String] The license plate number to be validated
    # @param type [Symbol, String, nil] :old_format, :mercosul, "old_format", or "mercosul".
    #   If not specified, checks for either format.
    #
    # @return [Boolean] True if the plate number is valid, false otherwise
    #
    # @example
    #   is_valid("ABC1234")
    #   #=> true (old format)
    #
    #   is_valid("ABC1D34")
    #   #=> true (Mercosul format)
    #
    #   is_valid("ABC-1234")
    #   #=> true (old format with dash)
    #
    #   is_valid("ABC1234", :old_format)
    #   #=> true
    #
    #   is_valid("ABC1D34", :old_format)
    #   #=> false
    #
    #   is_valid("ABC1D34", :mercosul)
    #   #=> true
    #
    #   is_valid("ABCD123")
    #   #=> false
    def self.is_valid(license_plate, type = nil)
      return false unless license_plate.is_a?(String)

      clean = remove_symbols(license_plate)

      type_str = type.to_s if type

      case type_str
      when 'old_format'
        valid_old_format?(clean)
      when 'mercosul'
        valid_mercosul?(clean)
      else
        valid_old_format?(clean) || valid_mercosul?(clean)
      end
    end

    # Alias for is_valid
    class << self
      alias valid? is_valid
    end

    # Removes the dash (-) symbol from a license plate string.
    #
    # @param license_plate_number [String] A license plate number containing symbols
    #
    # @return [String] The license plate number with dashes removed
    #
    # @example
    #   remove_symbols("ABC-1234")
    #   #=> "ABC1234"
    #
    #   remove_symbols("abc123")
    #   #=> "abc123"
    #
    #   remove_symbols("ABCD123")
    #   #=> "ABCD123"
    def self.remove_symbols(license_plate_number)
      return '' unless license_plate_number.is_a?(String)
      
      license_plate_number.gsub('-', '')
    end

    # Returns the format of a license plate.
    #
    # Returns 'LLLNNNN' for the old pattern and 'LLLNLNN' for the Mercosul one.
    #
    # @param license_plate [String] A license plate string without symbols
    #
    # @return [String, nil] The format of the license plate (LLLNNNN, LLLNLNN) or nil if invalid
    #
    # @example
    #   get_format("ABC1234")
    #   #=> "LLLNNNN"
    #
    #   get_format("abc1d23")
    #   #=> "LLLNLNN"
    #
    #   get_format("ABC-1234")
    #   #=> "LLLNNNN" (dash is removed automatically)
    #
    #   get_format("ABCD123")
    #   #=> nil
    def self.get_format(license_plate)
      return nil unless license_plate.is_a?(String)

      clean = remove_symbols(license_plate)

      if valid_old_format?(clean)
        'LLLNNNN'
      elsif valid_mercosul?(clean)
        'LLLNLNN'
      else
        nil
      end
    end

    # Generates a valid license plate in the given format.
    #
    # In case no format is provided, it will return a license plate in the Mercosul format.
    #
    # @param format [String] The desired format for the license plate.
    #   'LLLNNNN' for the old pattern or 'LLLNLNN' for the Mercosul one.
    #   Default is 'LLLNLNN'
    #
    # @return [String, nil] A randomly generated license plate number or nil if format is invalid
    #
    # @example
    #   generate
    #   #=> "ABC1D23" (Mercosul format by default)
    #
    #   generate('LLLNLNN')
    #   #=> "XYZ2E45" (Mercosul format)
    #
    #   generate('LLLNNNN')
    #   #=> "ABC1234" (old format)
    #
    #   generate('invalid')
    #   #=> nil
    def self.generate(format = 'LLLNLNN')
      format_upper = format.upcase

      return nil unless ['LLLNLNN', 'LLLNNNN'].include?(format_upper)

      generated = ''
      
      format_upper.each_char do |char|
        if char == 'L'
          # Generate random uppercase letter
          generated += ('A'..'Z').to_a.sample
        else  # char == 'N'
          # Generate random digit
          generated += rand(0..9).to_s
        end
      end

      generated
    end

    # Checks whether a string matches the old format of Brazilian license plate.
    #
    # Pattern: LLLNNNN (3 letters + 4 numbers)
    #
    # @param license_plate [String] The license plate to validate
    #
    # @return [Boolean] True if the plate matches old format, false otherwise
    #
    # @private
    def self.valid_old_format?(license_plate)
      return false unless license_plate.is_a?(String)

      OLD_FORMAT_PATTERN.match?(license_plate.strip)
    end

    private_class_method :valid_old_format?

    # Checks whether a string matches the Mercosul format of Brazilian license plate.
    #
    # Pattern: LLLNLNN (3 letters + 1 number + 1 letter + 2 numbers)
    #
    # @param license_plate [String] The license plate to validate
    #
    # @return [Boolean] True if the plate matches Mercosul format, false otherwise
    #
    # @private
    def self.valid_mercosul?(license_plate)
      return false unless license_plate.is_a?(String)

      MERCOSUL_PATTERN.match?(license_plate.upcase.strip)
    end

    private_class_method :valid_mercosul?
  end
end
