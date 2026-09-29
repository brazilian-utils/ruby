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
    ISO_DATE_REGEX = /^\d{4}-\d{2}-\d{2}$/.freeze

    MIN_YEAR = 1900
    MAX_YEAR = 2099

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

    # Lei 14.759/2023 made November 20th (Dia Nacional de Zumbi e da
    # Consciência Negra) a national holiday starting in 2024; before that it
    # was only a holiday in the states/cities that already had their own law
    # for it (some of which are still listed in STATE_HOLIDAYS below).
    NATIONAL_CONSCIENCIA_NEGRA_MONTH_DAY = [11, 20].freeze
    NATIONAL_CONSCIENCIA_NEGRA_EFFECTIVE_YEAR = 2024
    NATIONAL_CONSCIENCIA_NEGRA_NAME = 'Dia Nacional de Zumbi e da Consciência Negra'

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
    # Accepts either the legacy positional form `is_holiday(date, uf)` or a
    # single options Hash (as the contract's `IsHolidayParams`), e.g.
    # `is_holiday(date: Date.new(2024, 7, 9), state: 'SP')`.
    #
    # @param target_date [Date, DateTime, Time, Hash] The date to check, or
    #   an options Hash with `:date` and an optional `:state`/`:uf`.
    # @param uf [String, nil] The state abbreviation (UF) to check for state
    #   holidays, when `target_date` is not itself a Hash. An unknown UF is
    #   simply ignored (national holidays are still checked).
    #
    # @return [Boolean] true if the date is a holiday, false otherwise
    #   (including when the date is missing or invalid).
    #
    # @note This implementation includes fixed national and state holidays,
    #   plus the moveable Sexta-feira Santa (Good Friday).
    #
    # @example
    #   is_holiday(Date.new(2024, 1, 1))          #=> true (New Year)
    #   is_holiday(Date.new(2024, 1, 2))          #=> false
    #   is_holiday(Date.new(2024, 7, 9), 'SP')    #=> true (SP state holiday)
    #   is_holiday(date: Date.new(2024, 12, 25))  #=> true (Christmas)
    def self.is_holiday(target_date = nil, uf = nil)
      if target_date.is_a?(Hash)
        opts = target_date
        target_date = opts[:date] || opts['date']
        uf = opts[:state] || opts[:uf] || opts['state'] || opts['uf']
      end

      return false unless target_date.is_a?(Date) || target_date.is_a?(DateTime) || target_date.is_a?(Time)

      date = target_date.is_a?(Date) ? target_date : target_date.to_date
      return false unless date.year.between?(MIN_YEAR, MAX_YEAR)

      month_day = [date.month, date.day]

      return true if NATIONAL_HOLIDAYS.key?(month_day)

      if month_day == NATIONAL_CONSCIENCIA_NEGRA_MONTH_DAY && date.year >= NATIONAL_CONSCIENCIA_NEGRA_EFFECTIVE_YEAR
        return true
      end

      return true if date == good_friday(date.year)

      if uf
        state_uf = uf.to_s.upcase
        state_holidays = STATE_HOLIDAYS[state_uf]
        return true if state_holidays && state_holidays.key?(month_day)
      end

      false
    end

    # Returns the date of Easter Sunday (Domingo de Páscoa) for a given
    # Gregorian year, via the anonymous Gregorian computus algorithm
    # (Meeus/Jones/Butcher).
    #
    # @param year [Integer]
    # @return [Date]
    #
    # @private
    def self.easter_sunday(year)
      a = year % 19
      b = year / 100
      c = year % 100
      d = b / 4
      e = b % 4
      f = (b + 8) / 25
      g = (b - f + 1) / 3
      h = (19 * a + b - d - g + 15) % 30
      i = c / 4
      k = c % 4
      l = (32 + 2 * e + 2 * i - h - k) % 7
      m = (a + 11 * h + 22 * l) / 451
      month = (h + l - 7 * m + 114) / 31
      day = ((h + l - 7 * m + 114) % 31) + 1
      Date.new(year, month, day)
    end

    private_class_method :easter_sunday

    # @private
    def self.good_friday(year)
      easter_sunday(year) - 2
    end

    private_class_method :good_friday

    # @private
    def self.carnaval_monday(year)
      easter_sunday(year) - 48
    end

    private_class_method :carnaval_monday

    # @private
    def self.carnaval_tuesday(year)
      easter_sunday(year) - 47
    end

    private_class_method :carnaval_tuesday

    # @private
    def self.corpus_christi(year)
      easter_sunday(year) + 60
    end

    private_class_method :corpus_christi

    # Returns the Brazilian holidays of a given year, sorted by date.
    #
    # Each holiday is a Hash with `:name`, `:date` (a `Date`) and `:type`
    # (`:national`, `:state`, `:optional` or `:religious`).
    #
    # @param year [Integer] A year between 1900 and 2099.
    # @return [Array<Hash>] The holidays, sorted by date; an empty array when
    #   `year` is out of range.
    #
    # @example
    #   get_holidays(2024).first
    #   #=> { name: "Ano Novo", date: #<Date: 2024-01-01>, type: :national }
    def self.get_holidays(year)
      return [] unless year.is_a?(Integer) && year.between?(MIN_YEAR, MAX_YEAR)

      holidays = []

      NATIONAL_HOLIDAYS.each do |(month, day), name|
        holidays << { name: name, date: Date.new(year, month, day), type: :national }
      end

      if year >= NATIONAL_CONSCIENCIA_NEGRA_EFFECTIVE_YEAR
        holidays << {
          name: NATIONAL_CONSCIENCIA_NEGRA_NAME,
          date: Date.new(year, *NATIONAL_CONSCIENCIA_NEGRA_MONTH_DAY),
          type: :national
        }
      end

      holidays << { name: 'Sexta-feira Santa', date: good_friday(year), type: :religious }
      holidays << { name: 'Carnaval', date: carnaval_monday(year), type: :optional }
      holidays << { name: 'Carnaval', date: carnaval_tuesday(year), type: :optional }
      holidays << { name: 'Corpus Christi', date: corpus_christi(year), type: :optional }

      holidays.sort_by { |h| h[:date] }
    end

    # @private
    def self.coerce_date(value)
      case value
      when Date, DateTime, Time
        value.is_a?(Date) ? value : value.to_date
      else
        nil
      end
    end

    private_class_method :coerce_date

    # Checks whether a date is a Brazilian business day (dia útil): not a
    # Saturday, a Sunday, nor a holiday from {get_holidays}.
    #
    # @param value [Date, DateTime, Time] The date to check.
    # @param options [Hash] `:optional` (default true) also counts Carnaval
    #   and Corpus Christi; `:state`/`:uf` also counts that state's holidays.
    # @return [Boolean] false for an invalid date or one outside 1900..2099.
    def self.is_business_day(value, options = {})
      date = coerce_date(value)
      return false unless date
      return false unless date.year.between?(MIN_YEAR, MAX_YEAR)
      return false if [0, 6].include?(date.wday) # Sunday = 0, Saturday = 6

      count_optional = options[:optional].nil? && options['optional'].nil? ? true : (options[:optional] || options['optional'])
      state = options[:state] || options[:uf] || options['state'] || options['uf']

      holidays = get_holidays(date.year)
      holidays.concat(get_holidays(date.year - 1), get_holidays(date.year + 1)) if date.month == 1 || date.month == 12

      holidays.each do |holiday|
        next if holiday[:date] != date
        next if holiday[:type] == :optional && !count_optional

        return false
      end

      if state
        state_uf = state.to_s.upcase
        state_holidays = STATE_HOLIDAYS[state_uf]
        return false if state_holidays && state_holidays.key?([date.month, date.day])
      end

      true
    end

    class << self
      alias business_day? is_business_day
    end

    # Adds (or, with a negative amount, subtracts) a number of Brazilian
    # business days to a date, skipping weekends and holidays.
    #
    # @param date [Date, DateTime, Time] The starting date.
    # @param amount [Integer] The number of business days to add.
    # @param options [Hash] Same as {is_business_day}.
    # @return [Date, DateTime, Time, nil] A new date/time of the same class
    #   as the input (time of day preserved), or nil for an invalid date, a
    #   non-integer amount, or a result outside 1900..2099.
    def self.add_business_days(date, amount, options = {})
      return nil unless date.is_a?(Date) || date.is_a?(DateTime) || date.is_a?(Time)
      return nil unless amount.is_a?(Integer)

      base_date = coerce_date(date)
      return nil unless base_date

      remaining = amount.abs
      step = amount.negative? ? -1 : 1
      current = base_date

      while remaining.positive?
        current += step
        remaining -= 1 if is_business_day(current, options)
      end

      return nil unless current.year.between?(MIN_YEAR, MAX_YEAR)

      diff_days = (current - base_date).to_i
      date + diff_days
    end

    # Subtracts a number of Brazilian business days from a date.
    #
    # @param date [Date, DateTime, Time] The starting date.
    # @param amount [Integer] The number of business days to subtract.
    # @param options [Hash] Same as {is_business_day}.
    # @return [Date, DateTime, Time, nil] See {add_business_days}.
    def self.sub_business_days(date, amount, options = {})
      return nil unless amount.is_a?(Integer)

      add_business_days(date, -amount, options)
    end

    # Counts the Brazilian business days between two dates: `earlier_date`
    # (when it is itself a business day) and every business day strictly
    # between the two; `later_date` is never counted.
    #
    # @param later_date [Date, DateTime, Time]
    # @param earlier_date [Date, DateTime, Time]
    # @param options [Hash] Same as {is_business_day}.
    # @return [Integer, nil] Negative when `later_date` precedes
    #   `earlier_date`; 0 on the same calendar day; nil when either date is
    #   invalid or outside 1900..2099.
    def self.difference_in_business_days(later_date, earlier_date, options = {})
      later = coerce_date(later_date)
      earlier = coerce_date(earlier_date)
      return nil unless later && earlier
      return nil unless later.year.between?(MIN_YEAR, MAX_YEAR) && earlier.year.between?(MIN_YEAR, MAX_YEAR)

      return 0 if later == earlier

      if later > earlier
        count = 0
        d = earlier
        while d < later
          count += 1 if is_business_day(d, options)
          d += 1
        end
        count
      else
        -difference_in_business_days(earlier, later, options)
      end
    end

    # Converts a given date to its textual representation in Brazilian
    # Portuguese ("por extenso"), e.g. `"primeiro de janeiro de dois mil e
    # vinte e quatro"`.
    #
    # @param date [String, Date, DateTime, Time] The date to convert. A
    #   string may be `dd/mm/yyyy` or ISO `yyyy-mm-dd`.
    #
    # @return [String] The date written out in Brazilian Portuguese (all
    #   lower case), or an empty string when the date is invalid.
    #
    # @example
    #   convert_date_to_text("01/01/2024")  #=> "primeiro de janeiro de dois mil e vinte e quatro"
    #   convert_date_to_text("15/03/2024")  #=> "quinze de março de dois mil e vinte e quatro"
    #   convert_date_to_text("invalid")     #=> ""
    def self.convert_date_to_text(date)
      dt =
        case date
        when Date, DateTime, Time
          date.is_a?(Date) ? date : date.to_date
        when String
          parse_text_date(date)
        end

      return '' unless dt

      day = dt.day
      month = dt.month
      year = dt.year

      # Convert day to text (special case for 1st)
      day_str = day == 1 ? 'primeiro' : number_to_words(day)

      month_name = Months.name(month)
      year_str = number_to_words(year)

      "#{day_str} de #{month_name} de #{year_str}"
    end

    # Parses a `dd/mm/yyyy` or ISO `yyyy-mm-dd` date string.
    #
    # @return [Date, nil]
    #
    # @private
    def self.parse_text_date(date)
      return nil unless date.is_a?(String)

      if DATE_REGEX.match?(date)
        begin
          return Date.strptime(date, '%d/%m/%Y')
        rescue ArgumentError
          return nil
        end
      end

      if ISO_DATE_REGEX.match?(date)
        begin
          return Date.strptime(date, '%Y-%m-%d')
        rescue ArgumentError
          return nil
        end
      end

      nil
    end

    private_class_method :parse_text_date

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
