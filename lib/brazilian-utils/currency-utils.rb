require 'bigdecimal'

module BrazilianUtils
  module CurrencyUtils
    # Splits a BRL-ish amount string into its integer and decimal parts.
    #
    # The last `,` or `.` followed by 1 to `decimal_max` digits and then the
    # end of the string is treated as the decimal separator; every other `,`
    # or `.` found before it is treated as a thousands separator and removed.
    #
    # @param str [String] The (already symbol-stripped) amount string.
    # @param decimal_max [Integer] Maximum length of a trailing decimal run.
    # @return [Array(String, String, Boolean, Boolean)] integer part (digits
    #   only), decimal part (digits only, '' when none), whether a decimal
    #   separator was found, and whether the value is negative.
    #
    # @private
    def self.split_amount(str, decimal_max)
      cleaned = str.to_s.gsub(/[^\d.,\-]/, '')
      negative = cleaned.start_with?('-')
      cleaned = cleaned.sub(/\A-/, '')

      return ['0', '', false, negative] if cleaned.empty?

      last_sep_idx = cleaned.rindex(/[.,]/)
      integer_part = cleaned
      decimal_part = ''
      has_decimal = false

      if last_sep_idx
        after = cleaned[(last_sep_idx + 1)..-1]
        if after.length.between?(1, decimal_max) && after.match?(/\A\d+\z/)
          has_decimal = true
          decimal_part = after
          integer_part = cleaned[0...last_sep_idx]
        end
      end

      integer_part = integer_part.gsub(/[.,]/, '')
      integer_part = '0' if integer_part.empty?

      [integer_part, decimal_part, has_decimal, negative]
    end

    private_class_method :split_amount

    # Clamps a requested decimal precision to the 0..20 range, defaulting to 2.
    #
    # @private
    def self.clamp_precision(precision)
      value = precision.nil? ? 2 : precision.to_i
      value.clamp(0, 20)
    end

    private_class_method :clamp_precision

    # Parses a Brazilian currency string (e.g. `"R$ 1.234,56"`) into a Float.
    #
    # A value with no thousands/decimal separator at all is read as cents
    # (divided by 10 to the power of the precision); an empty string is 0.
    #
    # @param value [String] The value to parse.
    # @param options [Hash] `:precision` sets the number of decimal places
    #   assumed for a separator-less value (default 2).
    # @return [Float] The parsed amount.
    #
    # @example
    #   parse_currency("R$ 1.234,56")  #=> 1234.56
    #   parse_currency("1234")         #=> 12.34
    #   parse_currency("")             #=> 0
    def self.parse_currency(value, options = {})
      precision = clamp_precision(options[:precision] || options['precision'])
      str = value.to_s
      return 0 if str.strip.empty?

      integer_part, decimal_part, has_decimal, negative = split_amount(str, [precision, 2].max)

      amount = if has_decimal
                 "#{integer_part}.#{decimal_part}".to_f
               else
                 integer_part.to_i / (10.0**precision)
               end

      amount = -amount if negative
      amount
    end

    class << self
      alias parse parse_currency
    end

    # Formats a numeric value (or a currency-like string) as Brazilian
    # currency, e.g. `1234.56` becomes `"1.234,56"`.
    #
    # No currency symbol is added by default; pass `options[:symbol] = true`
    # to prefix the result with `"R$ "`.
    #
    # @param value [Float, Integer, String, BigDecimal] The value to format.
    # @param options [Hash] `:precision` (default 2, clamped to 0..20) sets
    #   the number of decimal places; `:symbol` (default false) prefixes
    #   `"R$ "`.
    # @return [String, nil] Formatted currency string, or nil if invalid.
    #
    # @example
    #   format_currency(1234.56)              #=> "1.234,56"
    #   format_currency(1234.56, symbol: true) #=> "R$ 1.234,56"
    #   format_currency("1.234,56")            #=> "1.234,56"
    #   format_currency("invalid")             #=> nil
    def self.format_currency(value, options = {})
      precision = clamp_precision(options[:precision] || options['precision'])
      symbol = options[:symbol] || options['symbol']

      amount =
        case value
        when Numeric
          value.to_f
        when String
          return nil if value.strip.empty?
          return nil unless value.match?(/\d/)

          integer_part, decimal_part, has_decimal, negative = split_amount(value, [precision, 2].max)
          n = has_decimal ? "#{integer_part}.#{decimal_part}".to_f : integer_part.to_f
          negative ? -n : n
        else
          return nil
        end

      return nil unless amount.finite?

      formatted = sprintf("%.#{precision}f", amount)
      sign = ''
      if formatted.start_with?('-')
        sign = '-'
        formatted = formatted[1..-1]
      end

      integer_str, decimal_str = formatted.split('.')
      integer_str = integer_str.chars.reverse.each_slice(3).map(&:join).join('.').reverse

      result = "#{sign}#{integer_str}"
      result += ",#{decimal_str}" if decimal_str
      symbol ? "R$ #{result}" : result
    rescue ArgumentError, TypeError, FloatDomainError
      nil
    end

    class << self
      alias format format_currency
    end

    # Converts a monetary value in Brazilian Reais to textual representation.
    #
    # @param amount [BigDecimal, Float, Integer, String] Monetary value to convert.
    # @return [String, nil] Textual representation in Brazilian Portuguese
    #   (all lower case), or nil if invalid.
    #
    # @note
    #   - Values are truncated (not rounded) to 2 decimal places
    #   - Maximum supported value is 1 quadrillion reais
    #   - Negative values are prefixed with "menos"
    #
    # @example
    #   convert_real_to_text(1523.45)
    #   #=> "mil quinhentos e vinte e três reais e quarenta e cinco centavos"
    #
    #   convert_real_to_text(1.00)
    #   #=> "um real"
    #
    #   convert_real_to_text(0.50)
    #   #=> "cinquenta centavos"
    #
    #   convert_real_to_text(0.00)
    #   #=> "zero reais"
    def self.convert_real_to_text(amount)
      # Convert to BigDecimal and round down to 2 decimal places
      decimal_amount = BigDecimal(amount.to_s)
      decimal_amount = decimal_amount.truncate(2)

      # Check for invalid values
      return nil if decimal_amount.nan? || decimal_amount.infinite?
      return nil if decimal_amount.abs > BigDecimal('1000000000000000.00') # 1 quadrillion

      negative = decimal_amount < 0
      decimal_amount = decimal_amount.abs

      reais = decimal_amount.to_i
      centavos = ((decimal_amount - reais) * 100).to_i

      parts = []

      if reais > 0
        reais_text = number_to_words(reais)
        currency_text = reais == 1 ? 'real' : 'reais'
        # "de" only applies when the text ends in "milhão(ões)"/"bilhão(ões)"/...
        # on its own (e.g. "um milhão de reais"), not when it's followed by
        # more words (e.g. "um milhão e um reais", no "de").
        conector = reais_text.match?(/lhão$|lhões$/) ? 'de ' : ''
        parts << "#{reais_text} #{conector}#{currency_text}"
      end

      if centavos > 0
        centavos_text = "#{number_to_words(centavos)} #{centavos == 1 ? 'centavo' : 'centavos'}"
        if reais > 0
          parts << "e #{centavos_text}"
        else
          parts << centavos_text
        end
      end

      if reais == 0 && centavos == 0
        parts << 'zero reais'
      end

      result = parts.join(' ')
      result = "menos #{result}" if negative

      result
    rescue ArgumentError, TypeError
      nil
    end

    # Converts a number to its textual representation in Brazilian Portuguese.
    #
    # @param number [Integer] The number to convert (0 to 999,999,999,999,999,999)
    # @return [String] The textual representation
    #
    # @private
    def self.number_to_words(number)
      number = number.to_i.abs
      return 'zero' if number.zero?

      # Scale names
      scales = [
        '',
        'mil',
        'milhão',
        'bilhão',
        'trilhão',
        'quadrilhão'
      ]

      scales_plural = [
        '',
        'mil',
        'milhões',
        'bilhões',
        'trilhões',
        'quadrilhões'
      ]

      # Break number into groups of 3 digits, lowest order first
      # (groups[0] is units-hundreds, groups[1] is thousands, ...)
      groups = []
      temp = number
      while temp > 0
        groups << temp % 1000
        temp /= 1000
      end

      parts = []
      groups.each_with_index do |group, index|
        next if group.zero?

        group_text = convert_group(group)
        scale_name = group == 1 ? scales[index] : scales_plural[index]

        parts << if scale_name.empty?
                   group_text
                 elsif index == 1 && group == 1 # "mil" doesn't need "um" before it
                   scale_name
                 else
                   "#{group_text} #{scale_name}"
                 end
      end

      # parts was built lowest-order group first; the spoken form reads
      # highest order first (e.g. "mil duzentos e trinta e quatro", not
      # "duzentos e trinta e quatro, mil").
      parts.reverse!
      return parts.first if parts.length == 1

      # The lowest-order non-zero group (spoken last) gets an "e" in front
      # when it reads as a single small/round term: below 100, or an exact
      # multiple of 100 (e.g. "mil e quatrocentos", "mil e um"); otherwise
      # groups are simply concatenated with a space, no comma
      # (Manual de Redação da Presidência: "mil duzentos e cinquenta reais").
      final_group = groups.find { |g| !g.zero? }
      last = parts.pop
      separator = (final_group < 100 || (final_group % 100).zero?) ? ' e ' : ' '
      "#{parts.join(' ')}#{separator}#{last}"
    end

    # Converts a group of 3 digits (0-999) to words.
    #
    # @param number [Integer] Number between 0 and 999
    # @return [String] The textual representation
    #
    # @private
    def self.convert_group(number)
      ones = %w[zero um dois três quatro cinco seis sete oito nove]
      tens = %w[dez onze doze treze quatorze quinze dezesseis dezessete dezoito dezenove]
      tens_multiples = %w[_ _ vinte trinta quarenta cinquenta sessenta setenta oitenta noventa]
      hundreds = %w[
        _
        cento
        duzentos
        trezentos
        quatrocentos
        quinhentos
        seiscentos
        setecentos
        oitocentos
        novecentos
      ]

      return ones[number] if number < 10

      if number < 20
        return tens[number - 10]
      end

      if number < 100
        tens_digit = number / 10
        ones_digit = number % 10
        if ones_digit.zero?
          return tens_multiples[tens_digit]
        else
          return "#{tens_multiples[tens_digit]} e #{ones[ones_digit]}"
        end
      end

      # 100-999
      hundreds_digit = number / 100
      remainder = number % 100

      if number == 100
        'cem'
      elsif remainder.zero?
        hundreds[hundreds_digit]
      else
        "#{hundreds[hundreds_digit]} e #{convert_group(remainder)}"
      end
    end

    private_class_method :number_to_words, :convert_group
  end
end
