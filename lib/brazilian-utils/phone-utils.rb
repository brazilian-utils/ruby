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

    # Códigos Não Geográficos (Anatel) that take 7 digits.
    SERVICE_CNG_PREFIXES = %w[0300 0303 0500 0800 0900].freeze

    # 3-digit public-utility numbers designated by Anatel (não exaustivo).
    SERVICE_SHORT_CODES = %w[
      100 101 102 104 105 106 107 108 110 111 116 118 119 120 121 122 123
      125 126 127 128 129 130 131 132 133 135 136 137 138 140 141 144 145
      146 147 148 150 151 152 153 154 155 156 158 159 160 161 162 163 164
      171 172 173 174 175 176 177 178 179 180 181 185 188 189 190 191 192
      193 194 195 196 197 198 199
    ].freeze

    # Removes a leading country code (`+55`, `0055` or a bare `55`) from an
    # already digits-only string, but only when doing so leaves 10 or 11
    # digits (so a DDD of `55`, e.g. Rio Grande do Sul, is not mistaken for
    # the country code).
    #
    # @param digits [String] A digits-only phone number.
    # @return [String] The digits, with the country code removed if applicable.
    #
    # @private
    def self.strip_country_code(digits)
      if digits.start_with?('0055') && [10, 11].include?(digits.length - 4)
        digits[4..-1]
      elsif digits.start_with?('55') && [10, 11].include?(digits.length - 2)
        digits[2..-1]
      else
        digits
      end
    end

    private_class_method :strip_country_code

    # Removes phone formatting and keeps only digits, capped to 11 digits.
    #
    # A country code (`+55`, `0055` or a bare `55`) is stripped only when 10
    # or 11 digits are left, so an area code of `55` is not mistaken for it.
    #
    # @param value [String, Integer] The value to parse.
    # @return [String] The parsed digits.
    #
    # @example
    #   parse("(11) 98888-7777")     #=> "11988887777"
    #   parse("+55 11 98888-7777")   #=> "11988887777"
    #   parse("55988887777")         #=> "55988887777" (55 read as DDD)
    def self.parse(value)
      return '' unless value.is_a?(String) || value.is_a?(Integer)

      digits = value.to_s.gsub(/\D/, '')
      return '' if digits.empty?

      strip_country_code(digits)[0, 11]
    end

    # Formats a Brazilian phone number.
    #
    # Without `options`, formats as the subscriber number only (`sn` mask,
    # no DDD): e.g. `"988887777"` becomes `"98888-7777"`. Other masks:
    # `:ddd` (`(11) 99402-9275`), `:e164` (`+5511994029275`),
    # `:international` (`+55 11 99402-9275`) and `:service`
    # (`0800 123 4567`).
    #
    # @param phone [String, Integer] A phone number, with or without formatting.
    # @param options [Hash] `:mask` picks the mask (default `:sn`).
    #
    # @return [String] The formatted phone number, or an empty string when
    #   there is nothing to format.
    #
    # @example
    #   format_phone("988887777")     #=> "98888-7777"
    #   format_phone("1130000000")    #=> "11300-0000"
    #   format_phone("11994029275", mask: :ddd) #=> "(11) 99402-9275"
    def self.format_phone(phone, options = {})
      return '' unless phone.is_a?(String) || phone.is_a?(Integer)

      digits = phone.to_s.gsub(/\D/, '')
      return '' if digits.empty?

      mask = (options[:mask] || options['mask'] || :sn).to_s

      case mask
      when 'ddd'
        format_ddd_mask(digits)
      when 'e164'
        format_e164_mask(digits)
      when 'international'
        format_international_mask(digits)
      when 'service'
        format_service_mask(digits)
      else
        format_subscriber_number_mask(digits)
      end
    end

    # Alias for format_phone
    class << self
      alias format format_phone
    end

    # @private
    def self.format_subscriber_number_mask(digits)
      d = digits[0, [digits.length, 9].min]
      return d if d.length <= 5

      "#{d[0, 5]}-#{d[5..-1]}"
    end

    private_class_method :format_subscriber_number_mask

    # @private
    def self.format_ddd_mask(digits)
      d = strip_country_code(digits)
      return '' unless d.length == 10 || d.length == 11

      ddd = d[0, 2]
      subscriber = d[2..-1]
      "(#{ddd}) #{subscriber[0..-5]}-#{subscriber[-4..-1]}"
    end

    private_class_method :format_ddd_mask

    # @private
    def self.format_e164_mask(digits)
      d = strip_country_code(digits)
      return '' unless d.length == 10 || d.length == 11

      "+55#{d}"
    end

    private_class_method :format_e164_mask

    # @private
    def self.format_international_mask(digits)
      d = strip_country_code(digits)
      return '' unless d.length == 10 || d.length == 11

      ddd = d[0, 2]
      subscriber = d[2..-1]
      "+55 #{ddd} #{subscriber[0..-5]}-#{subscriber[-4..-1]}"
    end

    private_class_method :format_international_mask

    # @private
    def self.format_service_mask(digits)
      if digits.length == 11 && SERVICE_CNG_PREFIXES.include?(digits[0, 4])
        "#{digits[0, 4]} #{digits[4, 3]} #{digits[7, 4]}"
      elsif digits.length == 8
        "#{digits[0, 4]}-#{digits[4, 4]}"
      else
        digits
      end
    end

    private_class_method :format_service_mask

    # Returns if a Brazilian phone number is valid (mobile or landline).
    #
    # A country code (`+55`, `0055` or a bare `55`) is accepted and removed
    # first, as in {parse}.
    #
    # @param phone_number [String] The phone number to validate.
    # @param type [Symbol, String, Hash, nil] :mobile, :landline, "mobile",
    #   "landline", or a Hash of options (`:type`, `:mobile_version`).
    #   If not specified, checks for either type.
    #
    # @return [Boolean] True if the phone number is valid, false otherwise
    #
    # @example
    #   is_valid("11994029275")   #=> true (mobile)
    #   is_valid("1635014415")    #=> true (landline)
    #   is_valid("+5511994029275") #=> true (country code stripped first)
    def self.is_valid(phone_number, type = nil)
      return false unless phone_number.is_a?(String)

      options = type.is_a?(Hash) ? type : { type: type }
      type_str = options[:type] ? options[:type].to_s : nil
      mobile_version = options[:mobile_version] || 1

      digits = phone_number.to_s.gsub(/\D/, '')
      return false if digits.empty?

      value = strip_country_code(digits)

      case type_str
      when 'mobile'
        mobile_number_matches?(value, mobile_version)
      when 'landline'
        landline_number_matches?(value)
      when 'service'
        service_number_matches?(value)
      else
        mobile_number_matches?(value, mobile_version) || landline_number_matches?(value)
      end
    end

    # Alias for is_valid
    class << self
      alias valid? is_valid
    end

    # Validates if a phone number is a valid Brazilian mobile phone (DDD +
    # 9 digits). A country code is accepted and removed first, as in {parse}.
    #
    # @param value [String] The phone number to validate.
    # @param options [Hash] `:version` 1 (default, subscriber digit 6-9) or
    #   2 (Resolução Anatel nº 749/2022: subscriber digit 7-9, no 700 series).
    # @return [Boolean]
    def self.is_valid_mobile(value, options = {})
      return false unless value.is_a?(String)

      digits = value.to_s.gsub(/\D/, '')
      return false if digits.empty?

      version = options[:version] || options['version'] || 1
      mobile_number_matches?(strip_country_code(digits), version)
    end

    class << self
      alias valid_mobile? is_valid_mobile
    end

    # Validates if a phone number is a valid Brazilian landline phone (DDD +
    # 8 digits). A country code is accepted and removed first, as in {parse}.
    #
    # @param value [String]
    # @return [Boolean]
    def self.is_valid_landline(value)
      return false unless value.is_a?(String)

      digits = value.to_s.gsub(/\D/, '')
      return false if digits.empty?

      landline_number_matches?(strip_country_code(digits))
    end

    class << self
      alias valid_landline? is_valid_landline
    end

    # Validates if a phone number is a valid Brazilian service number
    # (Código Não Geográfico or a 3-digit public-utility code).
    #
    # @param value [String]
    # @return [Boolean]
    def self.is_valid_service(value)
      return false unless value.is_a?(String)

      digits = value.to_s.gsub(/\D/, '')
      return false if digits.empty?

      service_number_matches?(digits)
    end

    class << self
      alias valid_service? is_valid_service
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

      # Only touch a "clean" digit string (with an optional leading '+') that
      # is longer than 11 digits; anything with spaces/hyphens/etc. is left
      # alone rather than partially stripped.
      digits_part = phone_number.sub(/\A\+/, '')

      if INTERNATIONAL_CODE_PATTERN.match?(phone_number) &&
         digits_part.match?(/\A\d+\z/) && digits_part.length > 11
        # Anchor to the start so only the leading "+55"/"55" is stripped
        # (a plain #sub would also drop the '+' and could hit an unrelated
        # "55" further into the number, e.g. an RS-state "55" DDD).
        phone_number.sub(/\A\+?55/, '')
      else
        phone_number
      end
    end

    # Returns if a Brazilian mobile number is valid.
    #
    # Mobile pattern: DDD (2 digits 1-9) + 9 + 8 digits (total 11 digits)
    #
    # @param phone_number [String] The mobile number to validate
    # @param version [Integer] 1 (default) or 2, see {is_valid_mobile}.
    #
    # @return [Boolean] True if valid mobile, false otherwise
    #
    # @private
    def self.mobile_number_matches?(phone_number, version = 1)
      return false unless phone_number.is_a?(String)
      return false unless MOBILE_PATTERN.match?(phone_number.strip)

      subscriber_first_digit = phone_number.strip[3]

      case version.to_i
      when 2
        return false unless %w[7 8 9].include?(subscriber_first_digit)
        return false if phone_number.strip[3, 3] == '700'

        true
      else
        true
      end
    end

    private_class_method :mobile_number_matches?

    # Returns if a Brazilian landline number is valid.
    #
    # Landline pattern: DDD (2 digits 1-9) + [2-5] + 7 digits (total 10 digits)
    #
    # @param phone_number [String] The landline number to validate
    #
    # @return [Boolean] True if valid landline, false otherwise
    #
    # @private
    def self.landline_number_matches?(phone_number)
      return false unless phone_number.is_a?(String)

      LANDLINE_PATTERN.match?(phone_number.strip)
    end

    private_class_method :landline_number_matches?

    # Returns if a value is a valid Brazilian service number.
    #
    # @param value [String] Digits-only phone number.
    # @return [Boolean]
    #
    # @private
    def self.service_number_matches?(value)
      return false unless value.is_a?(String)

      v = value.strip

      return true if v.length == 11 && SERVICE_CNG_PREFIXES.include?(v[0, 4])
      return true if v.length == 8 && %w[300 400].include?(v[0, 3])
      return true if v.length == 3 && SERVICE_SHORT_CODES.include?(v)

      false
    end

    private_class_method :service_number_matches?

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
