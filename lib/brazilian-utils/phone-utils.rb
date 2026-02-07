module BrazilianUtils
  # Utilities for formatting, validating, and generating Brazilian phone numbers.
  #
  # Brazilian phone numbers come in two types:
  # - Mobile (Celular): 11 digits - DDD (2 digits) + 9 + 8 digits, e.g., "11994029275"
  # - Landline (Fixo): 10 digits - DDD (2 digits) + [2-5] + 7 digits, e.g., "1635014415"
  #
  # DDD (Discagem Direta à Distância) is the area code, ranging from 11 to 99.
  # Mobile numbers always have 9 as the 3rd digit (after DDD).
  # Landline numbers have 2, 3, 4, or 5 as the 3rd digit (after DDD).
  module PhoneUtils
    # Pattern for mobile phone numbers (11 digits: DDD + 9 + 8 digits)
    MOBILE_PATTERN = /^[1-9][1-9][9]\d{8}$/.freeze
    
    # Pattern for landline phone numbers (10 digits: DDD + [2-5] + 7 digits)
    LANDLINE_PATTERN = /^[1-9][1-9][2-5]\d{7}$/.freeze

    # Pattern for international dialing code (+55 or 55)
    INTERNATIONAL_CODE_PATTERN = /\+?55/.freeze

    # Formats a Brazilian phone number into the standard pattern.
    #
    # Formats as (DD)NNNNN-NNNN for both mobile and landline numbers.
    #
    # @param phone [String] A string representing the phone number (digits only)
    #
    # @return [String, nil] The formatted phone number or nil if invalid
    #
    # @example
    #   format_phone("11994029275")
    #   #=> "(11)99402-9275"
    #
    #   format_phone("1635014415")
    #   #=> "(16)3501-4415"
    #
    #   format_phone("333333")
    #   #=> nil
    def self.format_phone(phone)
      return nil unless is_valid(phone)

      ddd = phone[0..1]
      phone_number = phone[2..-1]

      "(#{ddd})#{phone_number[0..-5]}-#{phone_number[-4..-1]}"
    end

    # Alias for format_phone
    class << self
      alias format format_phone
    end

    # Returns if a Brazilian phone number is valid.
    #
    # It does not verify if the number actually exists.
    #
    # @param phone_number [String] The phone number to validate (digits only, no country code)
    # @param type [Symbol, String, nil] :mobile, :landline, "mobile", or "landline".
    #   If not specified, checks for either type.
    #
    # @return [Boolean] True if the phone number is valid, false otherwise
    #
    # @example
    #   is_valid("11994029275")
    #   #=> true (mobile)
    #
    #   is_valid("1635014415")
    #   #=> true (landline)
    #
    #   is_valid("11994029275", :mobile)
    #   #=> true
    #
    #   is_valid("1635014415", :mobile)
    #   #=> false
    #
    #   is_valid("1635014415", :landline)
    #   #=> true
    #
    #   is_valid("123456")
    #   #=> false
    def self.is_valid(phone_number, type = nil)
      return false unless phone_number.is_a?(String)

      type_str = type.to_s if type

      case type_str
      when 'mobile'
        valid_mobile?(phone_number)
      when 'landline'
        valid_landline?(phone_number)
      else
        valid_mobile?(phone_number) || valid_landline?(phone_number)
      end
    end

    # Alias for is_valid
    class << self
      alias valid? is_valid
    end

    # Removes common symbols from a Brazilian phone number string.
    #
    # Removes: (, ), -, +, and spaces
    #
    # @param phone_number [String] The phone number to remove symbols from
    #
    # @return [String] A new string with the specified symbols removed
    #
    # @example
    #   remove_symbols_phone("(11)99402-9275")
    #   #=> "11994029275"
    #
    #   remove_symbols_phone("+55 11 99402-9275")
    #   #=> "5511994029275"
    #
    #   remove_symbols_phone("(16) 3501-4415")
    #   #=> "1635014415"
    def self.remove_symbols_phone(phone_number)
      return '' unless phone_number.is_a?(String)

      phone_number.gsub(/[\(\)\-\+\s]/, '')
    end

    # Alias for remove_symbols_phone
    class << self
      alias remove_symbols remove_symbols_phone
      alias sieve remove_symbols_phone
    end

    # Generates a valid and random phone number.
    #
    # @param type [Symbol, String, nil] :mobile, :landline, "mobile", or "landline".
    #   If not specified, generates either type randomly.
    #
    # @return [String] A randomly generated valid phone number
    #
    # @example
    #   generate
    #   #=> "2234451215" (random type)
    #
    #   generate(:mobile)
    #   #=> "11999115895"
    #
    #   generate(:landline)
    #   #=> "1635317900"
    #
    #   generate("mobile")
    #   #=> "21987654321"
    def self.generate(type = nil)
      type_str = type.to_s if type

      case type_str
      when 'mobile'
        generate_mobile_phone
      when 'landline'
        generate_landline_phone
      else
        [method(:generate_mobile_phone), method(:generate_landline_phone)].sample.call
      end
    end

    # Removes the international dialing code (+55 or 55) from a phone number.
    #
    # Only removes the code if the resulting number has more than 11 digits.
    #
    # @param phone_number [String] The phone number with or without international code
    #
    # @return [String] The phone number without international code, or the same number if no code present
    #
    # @example
    #   remove_international_dialing_code("5511994029275")
    #   #=> "11994029275"
    #
    #   remove_international_dialing_code("+5511994029275")
    #   #=> "11994029275"
    #
    #   remove_international_dialing_code("1635014415")
    #   #=> "1635014415" (no international code)
    #
    #   remove_international_dialing_code("+55 11 99402-9275")
    #   #=> "+55 11 99402-9275" (has spaces, length check fails)
    def self.remove_international_dialing_code(phone_number)
      return '' unless phone_number.is_a?(String)

      # Check if pattern matches and length (without spaces) is > 11
      if INTERNATIONAL_CODE_PATTERN.match?(phone_number) && phone_number.gsub(' ', '').length > 11
        phone_number.sub('55', '')
      else
        phone_number
      end
    end

    # Returns if a Brazilian mobile number is valid.
    #
    # Mobile pattern: DDD (2 digits 1-9) + 9 + 8 digits (total 11 digits)
    #
    # @param phone_number [String] The mobile number to validate
    #
    # @return [Boolean] True if valid mobile, false otherwise
    #
    # @private
    def self.valid_mobile?(phone_number)
      return false unless phone_number.is_a?(String)

      MOBILE_PATTERN.match?(phone_number.strip)
    end

    private_class_method :valid_mobile?

    # Returns if a Brazilian landline number is valid.
    #
    # Landline pattern: DDD (2 digits 1-9) + [2-5] + 7 digits (total 10 digits)
    #
    # @param phone_number [String] The landline number to validate
    #
    # @return [Boolean] True if valid landline, false otherwise
    #
    # @private
    def self.valid_landline?(phone_number)
      return false unless phone_number.is_a?(String)

      LANDLINE_PATTERN.match?(phone_number.strip)
    end

    private_class_method :valid_landline?

    # Generates a valid DDD (area code) number.
    #
    # DDD consists of 2 digits, both ranging from 1-9.
    #
    # @return [String] A 2-digit DDD number
    #
    # @private
    def self.generate_ddd_number
      2.times.map { rand(1..9) }.join
    end

    private_class_method :generate_ddd_number

    # Generates a valid and random mobile phone number.
    #
    # Format: DDD + 9 + 8 random digits (total 11 digits)
    #
    # @return [String] A valid mobile phone number
    #
    # @private
    def self.generate_mobile_phone
      ddd = generate_ddd_number
      client_number = 8.times.map { rand(0..9) }.join

      "#{ddd}9#{client_number}"
    end

    private_class_method :generate_mobile_phone

    # Generates a valid and random landline phone number.
    #
    # Format: DDD + [2-5] + 7 random digits (total 10 digits)
    #
    # @return [String] A valid landline phone number
    #
    # @private
    def self.generate_landline_phone
      ddd = generate_ddd_number
      first_digit = rand(2..5)
      remaining_digits = rand(0..9999999).to_s.rjust(7, '0')

      "#{ddd}#{first_digit}#{remaining_digits}"
    end

    private_class_method :generate_landline_phone
  end
end
