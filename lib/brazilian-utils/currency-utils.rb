require 'bigdecimal'

module BrazilianUtils
  module CurrencyUtils
    # Formats a numeric value as Brazilian currency (R$).
    #
    # @param value [Float, Integer, String, BigDecimal] The numeric value to format.
    # @return [String, nil] Formatted currency string (e.g., "R$ 1.234,56") or nil if invalid.
    #
    # @example
    #   format_currency(1234.56)     #=> "R$ 1.234,56"
    #   format_currency(0)           #=> "R$ 0,00"
    #   format_currency(-9876.54)    #=> "R$ -9.876,54"
    #   format_currency("invalid")   #=> nil
    def self.format_currency(value)
      decimal_value = BigDecimal(value.to_s)
      
      # Format with 2 decimal places and thousands separator
      formatted = format('%.2f', decimal_value)
      
      # Split into integer and decimal parts
      integer_part, decimal_part = formatted.split('.')
      
      # Add thousands separator to integer part
      integer_part = integer_part.chars.reverse.each_slice(3).map(&:join).join('.').reverse
      
      # Combine with Brazilian format
      "R$ #{integer_part},#{decimal_part}"
    rescue ArgumentError, TypeError
      nil
    end

    # Converts a monetary value in Brazilian Reais to textual representation.
    #
    # @param amount [BigDecimal, Float, Integer, String] Monetary value to convert.
    # @return [String, nil] Textual representation in Brazilian Portuguese, or nil if invalid.
    #
    # @note
    #   - Values are rounded down to 2 decimal places
    #   - Maximum supported value is 1 quadrillion reais
    #   - Negative values are prefixed with "Menos"
    #
    # @example
    #   convert_real_to_text(1523.45)
    #   #=> "Mil quinhentos e vinte e três reais e quarenta e cinco centavos"
    #
    #   convert_real_to_text(1.00)
    #   #=> "Um real"
    #
    #   convert_real_to_text(0.50)
    #   #=> "Cinquenta centavos"
    #
    #   convert_real_to_text(0.00)
    #   #=> "Zero reais"
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
        parts << 'Zero reais'
      end
      
      result = parts.join(' ')
      result = "Menos #{result}" if negative
      
      result.capitalize
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
