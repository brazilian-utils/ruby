# frozen_string_literal: true

module BrazilianUtils
  # Utilities for writing numbers in Brazilian Portuguese cardinal words
  # ("por extenso"), e.g. `1235` becomes `"mil duzentos e trinta e cinco"`.
  module NumberUtils
    MAX_ABS_VALUE = 999_999_999_999_999

    FEMININE_GENDERS = %i[feminine feminino f].freeze

    # Writes an integer in Brazilian Portuguese cardinal words.
    #
    # @param value [Numeric] The number to convert. Accepts integers from
    #   -999,999,999,999,999 to 999,999,999,999,999; a non-integer is
    #   truncated toward zero.
    # @param options [Hash] `:gender` (`:masculine`, default, or
    #   `:feminine`) agrees "um/uma", "dois/duas" and the hundreds.
    # @return [String] The textual representation, or an empty string for a
    #   value outside the supported range or not finite.
    #
    # @example
    #   convert_to_words(1235)     #=> "mil duzentos e trinta e cinco"
    #   convert_to_words(100)      #=> "cem"
    #   convert_to_words(-3)       #=> "menos três"
    #   convert_to_words(2, gender: :feminine) #=> "duas"
    def self.convert_to_words(value, options = {})
      return '' unless value.is_a?(Numeric)
      return '' if value.respond_to?(:finite?) && !value.finite?

      int_value = value.to_i
      return '' if int_value.abs > MAX_ABS_VALUE

      gender = (options[:gender] || options['gender'] || :masculine).to_sym
      negative = int_value.negative?
      words = number_to_words(int_value.abs, gender)
      negative ? "menos #{words}" : words
    end

    # @private
    def self.number_to_words(number, gender = :masculine)
      return 'zero' if number.zero?

      scales = ['', 'mil', 'milhão', 'bilhão', 'trilhão']
      scales_plural = ['', 'mil', 'milhões', 'bilhões', 'trilhões']

      groups = []
      temp = number
      while temp > 0
        groups << temp % 1000
        temp /= 1000
      end

      parts = []
      groups.each_with_index do |group, index|
        next if group.zero?

        group_text = convert_group(group, gender)
        scale_name = group == 1 ? scales[index] : scales_plural[index]

        parts << if scale_name.empty?
                   group_text
                 elsif index == 1 && group == 1
                   scale_name
                 else
                   "#{group_text} #{scale_name}"
                 end
      end

      parts.reverse!
      return parts.first if parts.length == 1

      final_group = groups.find { |g| !g.zero? }
      last = parts.pop
      separator = (final_group < 100 || (final_group % 100).zero?) ? ' e ' : ' '
      "#{parts.join(' ')}#{separator}#{last}"
    end

    private_class_method :number_to_words

    # @private
    def self.convert_group(number, gender = :masculine)
      feminine = FEMININE_GENDERS.include?(gender)

      ones = %w[zero um dois três quatro cinco seis sete oito nove]
      ones_fem = %w[zero uma duas três quatro cinco seis sete oito nove]
      tens = %w[dez onze doze treze quatorze quinze dezesseis dezessete dezoito dezenove]
      tens_multiples = %w[_ _ vinte trinta quarenta cinquenta sessenta setenta oitenta noventa]
      hundreds_m = %w[
        _ cento duzentos trezentos quatrocentos quinhentos seiscentos setecentos oitocentos novecentos
      ]
      hundreds_f = %w[
        _ cento duzentas trezentas quatrocentas quinhentas seiscentas setecentas oitocentas novecentas
      ]

      ones_words = feminine ? ones_fem : ones
      hundreds = feminine ? hundreds_f : hundreds_m

      return ones_words[number] if number < 10
      return tens[number - 10] if number < 20

      if number < 100
        tens_digit = number / 10
        ones_digit = number % 10
        return tens_multiples[tens_digit] if ones_digit.zero?

        return "#{tens_multiples[tens_digit]} e #{ones_words[ones_digit]}"
      end

      hundreds_digit = number / 100
      remainder = number % 100

      if number == 100
        'cem'
      elsif remainder.zero?
        hundreds[hundreds_digit]
      else
        "#{hundreds[hundreds_digit]} e #{convert_group(remainder, gender)}"
      end
    end

    private_class_method :convert_group
  end
end
