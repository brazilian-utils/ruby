require 'date'

module BrazilianUtils
  # Brazilian months enumeration
  module Months
    NAMES = {
      1 => 'janeiro',
      2 => 'fevereiro',
      3 => 'março',
      4 => 'abril',
      5 => 'maio',
      6 => 'junho',
      7 => 'julho',
      8 => 'agosto',
      9 => 'setembro',
      10 => 'outubro',
      11 => 'novembro',
      12 => 'dezembro'
    }.freeze

    def self.name(month_number)
      NAMES[month_number]
    end
  end

  module DateUtils
    DATE_REGEX = /^\d{2}\/\d{2}\/\d{4}$/.freeze

    # Brazilian national holidays (fixed dates)
    NATIONAL_HOLIDAYS = {
      [1, 1] => 'Ano Novo',
      [4, 21] => 'Tiradentes',
      [5, 1] => 'Dia do Trabalho',
      [9, 7] => 'Independência do Brasil',
      [10, 12] => 'Nossa Senhora Aparecida',
      [11, 2] => 'Finados',
      [11, 15] => 'Proclamação da República',
      [12, 25] => 'Natal'
    }.freeze

    # State-specific holidays (fixed dates)
    STATE_HOLIDAYS = {
      'AC' => { [1, 23] => 'Dia do Evangélico', [6, 15] => 'Aniversário do Acre', [9, 5] => 'Dia da Amazônia', [11, 17] => 'Assinatura do Tratado de Petrópolis' },
      'AL' => { [6, 24] => 'São João', [6, 29] => 'São Pedro', [9, 16] => 'Emancipação Política', [11, 20] => 'Morte de Zumbi dos Palmares' },
      'AM' => { [9, 5] => 'Elevação do Amazonas à categoria de província' },
      'AP' => { [3, 19] => 'Dia de São José', [9, 13] => 'Criação do Território Federal' },
      'BA' => { [7, 2] => 'Independência da Bahia' },
      'CE' => { [3, 19] => 'São José', [3, 25] => 'Data Magna do Ceará' },
      'DF' => { [4, 21] => 'Fundação de Brasília', [11, 30] => 'Dia do Evangélico' },
      'ES' => { [4, 21] => 'Nossa Senhora da Penha' },
      'GO' => { [10, 24] => 'Pedra fundamental de Goiânia' },
      'MA' => { [7, 28] => 'Adesão do Maranhão à independência do Brasil' },
      'MG' => { [4, 21] => 'Data Magna de Minas Gerais' },
      'MS' => { [10, 11] => 'Criação do estado' },
      'MT' => { [11, 20] => 'Dia da Consciência Negra' },
      'PA' => { [8, 15] => 'Adesão do Grão-Pará à independência do Brasil' },
      'PB' => { [7, 26] => 'Homenagem à memória do ex-presidente João Pessoa', [8, 5] => 'Fundação do Estado em 1585' },
      'PE' => { [3, 6] => 'Revolução Pernambucana de 1817', [6, 24] => 'São João' },
      'PI' => { [10, 19] => 'Dia do Piauí' },
      'PR' => { [12, 19] => 'Emancipação política do Paraná' },
      'RJ' => { [4, 23] => 'Dia de São Jorge', [11, 20] => 'Dia da Consciência Negra' },
      'RN' => { [6, 29] => 'Dia de São Pedro', [10, 3] => 'Mártires de Cunhaú e Uruaçu' },
      'RO' => { [1, 4] => 'Criação do estado', [6, 18] => 'Dia do Evangélico' },
      'RR' => { [10, 5] => 'Criação de Roraima' },
      'RS' => { [9, 20] => 'Revolução Farroupilha' },
      'SC' => { [8, 11] => 'Criação da capitania, separando-se de SP' },
      'SE' => { [7, 8] => 'Autonomia política de Sergipe' },
      'SP' => { [7, 9] => 'Revolução Constitucionalista de 1932' },
      'TO' => { [10, 5] => 'Criação de Tocantins' }
    }.freeze

    VALID_UFS = %w[
      AC AL AP AM BA CE DF ES GO MA MT MS MG PA PB PR PE PI RJ RN RS RO RR SC SP SE TO
    ].freeze

    # Checks if the given date is a national or state holiday in Brazil.
    #
    # This function takes a date as a Date or DateTime object and an optional UF (Unidade Federativa),
    # returning a boolean value indicating whether the date is a holiday or nil if the date or
    # UF are invalid.
    #
    # The method does not handle municipal holidays.
    #
    # @param target_date [Date, DateTime, Time] The date to be checked.
    # @param uf [String, nil] The state abbreviation (UF) to check for state holidays.
    #   If not provided, only national holidays will be considered.
    #
    # @return [Boolean, nil] Returns true if the date is a holiday, false if it is not,
    #   or nil if the date or UF are invalid.
    #
    # @note This implementation includes fixed national and state holidays.
    #   Movable holidays (like Carnival, Easter) are not included in this basic implementation.
    #
    # @example
    #   is_holiday(Date.new(2024, 1, 1))          #=> true (New Year)
    #   is_holiday(Date.new(2024, 1, 2))          #=> false
    #   is_holiday(Date.new(2024, 7, 9), 'SP')    #=> true (SP state holiday)
    #   is_holiday(Date.new(2024, 12, 25), 'RJ')  #=> true (Christmas)
    def self.is_holiday(target_date, uf = nil)
      return nil unless target_date.is_a?(Date) || target_date.is_a?(DateTime) || target_date.is_a?(Time)

      # Convert to Date if needed
      date = target_date.is_a?(Date) ? target_date : target_date.to_date

      # Validate UF if provided
      if uf && !VALID_UFS.include?(uf.to_s.upcase)
        return nil
      end

      month_day = [date.month, date.day]

      # Check national holidays
      return true if NATIONAL_HOLIDAYS.key?(month_day)

      # Check state holidays if UF is provided
      if uf
        state_uf = uf.to_s.upcase
        state_holidays = STATE_HOLIDAYS[state_uf]
        return true if state_holidays && state_holidays.key?(month_day)
      end

      false
    end

    # Converts a given date in Brazilian format (dd/mm/yyyy) to its textual representation.
    #
    # This function takes a date as a string in the format dd/mm/yyyy and converts it
    # to a string with the date written out in Brazilian Portuguese, including the full
    # month name and the year.
    #
    # @param date [String] The date to be converted into text. Expected format: dd/mm/yyyy.
    #
    # @return [String, nil] A string with the date written out in Brazilian Portuguese,
    #   or nil if the date is invalid.
    #
    # @example
    #   convert_date_to_text("01/01/2024")  #=> "Primeiro de janeiro de dois mil e vinte e quatro"
    #   convert_date_to_text("15/03/2024")  #=> "Quinze de março de dois mil e vinte e quatro"
    #   convert_date_to_text("invalid")     #=> nil
    def self.convert_date_to_text(date)
      return nil unless DATE_REGEX.match?(date)

      begin
        dt = Date.strptime(date, '%d/%m/%Y')
      rescue ArgumentError
        return nil
      end

      day = dt.day
      month = dt.month
      year = dt.year

      # Convert day to text (special case for 1st)
      day_str = if day == 1
                  'Primeiro'
                else
                  # Reuse number_to_words from CurrencyUtils or implement inline
                  number_to_words(day).capitalize
                end

      month_name = Months.name(month)
      year_str = number_to_words(year)

      "#{day_str} de #{month_name} de #{year_str}"
    end

    # Converts a number to its textual representation in Brazilian Portuguese.
    # This is a simplified version focused on dates (days 1-31, years).
    #
    # @param number [Integer] The number to convert
    # @return [String] The textual representation
    #
    # @private
    def self.number_to_words(number)
      return 'zero' if number.zero?

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

      if number < 10
        return ones[number]
      elsif number < 20
        return tens[number - 10]
      elsif number < 100
        tens_digit = number / 10
        ones_digit = number % 10
        if ones_digit.zero?
          return tens_multiples[tens_digit]
        else
          return "#{tens_multiples[tens_digit]} e #{ones[ones_digit]}"
        end
      elsif number == 100
        return 'cem'
      elsif number < 1000
        hundreds_digit = number / 100
        remainder = number % 100
        if remainder.zero?
          return hundreds[hundreds_digit]
        else
          return "#{hundreds[hundreds_digit]} e #{number_to_words(remainder)}"
        end
      elsif number < 1_000_000
        # For years like 2024
        thousands = number / 1000
        remainder = number % 1000

        result = []
        
        if thousands == 1
          result << 'mil'
        else
          result << "#{number_to_words(thousands)} mil"
        end

        if remainder > 0
          if remainder < 100
            result << "e #{number_to_words(remainder)}"
          else
            result << number_to_words(remainder)
          end
        end

        result.join(' ')
      else
        number.to_s
      end
    end

    private_class_method :number_to_words
  end
end
