require 'spec_helper'

RSpec.describe BrazilianUtils::DateUtils do
  describe '.is_holiday' do
    context 'with national holidays' do
      it 'returns true for New Year (Jan 1)' do
        date = Date.new(2024, 1, 1)
        expect(described_class.is_holiday(date)).to be true
      end

      it 'returns true for Tiradentes Day (Apr 21)' do
        date = Date.new(2024, 4, 21)
        expect(described_class.is_holiday(date)).to be true
      end

      it 'returns true for Labor Day (May 1)' do
        date = Date.new(2024, 5, 1)
        expect(described_class.is_holiday(date)).to be true
      end

      it 'returns true for Independence Day (Sep 7)' do
        date = Date.new(2024, 9, 7)
        expect(described_class.is_holiday(date)).to be true
      end

      it 'returns true for Nossa Senhora Aparecida (Oct 12)' do
        date = Date.new(2024, 10, 12)
        expect(described_class.is_holiday(date)).to be true
      end

      it 'returns true for All Souls Day (Nov 2)' do
        date = Date.new(2024, 11, 2)
        expect(described_class.is_holiday(date)).to be true
      end

      it 'returns true for Proclamation of the Republic (Nov 15)' do
        date = Date.new(2024, 11, 15)
        expect(described_class.is_holiday(date)).to be true
      end

      it 'returns true for Christmas (Dec 25)' do
        date = Date.new(2024, 12, 25)
        expect(described_class.is_holiday(date)).to be true
      end

      it 'returns false for a regular day' do
        date = Date.new(2024, 3, 15)
        expect(described_class.is_holiday(date)).to be false
      end

      it 'returns false for a weekend that is not a holiday' do
        date = Date.new(2024, 3, 16) # Saturday
        expect(described_class.is_holiday(date)).to be false
      end
    end

    context 'with state holidays' do
      it 'returns true for São Paulo state holiday (Jul 9)' do
        date = Date.new(2024, 7, 9)
        expect(described_class.is_holiday(date, 'SP')).to be true
      end

      it 'returns false for São Paulo holiday when checking in Rio (Jul 9)' do
        date = Date.new(2024, 7, 9)
        expect(described_class.is_holiday(date, 'RJ')).to be false
      end

      it 'returns true for Rio state holiday (Nov 20 - Consciência Negra)' do
        date = Date.new(2024, 11, 20)
        expect(described_class.is_holiday(date, 'RJ')).to be true
      end

      it 'returns true for Bahia state holiday (Jul 2)' do
        date = Date.new(2024, 7, 2)
        expect(described_class.is_holiday(date, 'BA')).to be true
      end

      it 'returns true for Acre state holiday (Jun 15)' do
        date = Date.new(2024, 6, 15)
        expect(described_class.is_holiday(date, 'AC')).to be true
      end

      it 'returns true for Minas Gerais state holiday (Apr 21)' do
        date = Date.new(2024, 4, 21)
        expect(described_class.is_holiday(date, 'MG')).to be true
      end

      it 'returns false for a regular day in a specific state' do
        date = Date.new(2024, 3, 15)
        expect(described_class.is_holiday(date, 'SP')).to be false
      end

      it 'handles lowercase UF code' do
        date = Date.new(2024, 7, 9)
        expect(described_class.is_holiday(date, 'sp')).to be true
      end
    end

    context 'with invalid inputs' do
      it 'returns false for a non-Date/DateTime/Time argument' do
        expect(described_class.is_holiday('2024-01-01')).to be false
      end

      it 'returns false for nil date' do
        expect(described_class.is_holiday(nil)).to be false
      end

      it 'ignores an unknown UF and still checks national holidays' do
        date = Date.new(2024, 1, 1)
        expect(described_class.is_holiday(date, 'XX')).to be true
      end

      it 'ignores an unknown UF and returns false on a non-holiday' do
        date = Date.new(2024, 3, 15)
        expect(described_class.is_holiday(date, 'Invalid')).to be false
      end
    end

    context 'with the options Hash form' do
      it 'accepts date: and state: keys' do
        expect(described_class.is_holiday(date: Date.new(2024, 7, 9), state: 'SP')).to be true
      end

      it 'returns false when the options Hash has no date' do
        expect(described_class.is_holiday({})).to be false
      end
    end

    context 'with moveable feasts' do
      it 'recognizes Good Friday 2024 (Mar 29)' do
        expect(described_class.is_holiday(Date.new(2024, 3, 29))).to be true
      end

      it 'recognizes Good Friday 2025 (Apr 18)' do
        expect(described_class.is_holiday(Date.new(2025, 4, 18))).to be true
      end
    end

    context 'with different date types' do
      it 'works with Date objects' do
        date = Date.new(2024, 12, 25)
        expect(described_class.is_holiday(date)).to be true
      end

      it 'works with DateTime objects' do
        date = DateTime.new(2024, 12, 25, 10, 30, 0)
        expect(described_class.is_holiday(date)).to be true
      end

      it 'works with Time objects' do
        date = Time.new(2024, 12, 25, 10, 30, 0)
        expect(described_class.is_holiday(date)).to be true
      end
    end

    context 'across different years' do
      it 'recognizes Christmas in different years' do
        expect(described_class.is_holiday(Date.new(2023, 12, 25))).to be true
        expect(described_class.is_holiday(Date.new(2024, 12, 25))).to be true
        expect(described_class.is_holiday(Date.new(2025, 12, 25))).to be true
      end

      it 'recognizes state holidays in different years' do
        expect(described_class.is_holiday(Date.new(2023, 7, 9), 'SP')).to be true
        expect(described_class.is_holiday(Date.new(2024, 7, 9), 'SP')).to be true
        expect(described_class.is_holiday(Date.new(2025, 7, 9), 'SP')).to be true
      end
    end
  end

  describe '.convert_date_to_text' do
    context 'with valid dates' do
      it 'converts first day of the year' do
        result = described_class.convert_date_to_text('01/01/2024')
        expect(result).to eq('primeiro de janeiro de dois mil e vinte e quatro')
      end

      it 'converts a date with day 1' do
        result = described_class.convert_date_to_text('01/05/2024')
        expect(result).to eq('primeiro de maio de dois mil e vinte e quatro')
      end

      it 'converts a regular date' do
        result = described_class.convert_date_to_text('15/03/2024')
        expect(result).to eq('quinze de março de dois mil e vinte e quatro')
      end

      it 'converts a date with two-digit day' do
        result = described_class.convert_date_to_text('25/12/2023')
        expect(result).to eq('vinte e cinco de dezembro de dois mil e vinte e três')
      end

      it 'converts a date in February' do
        result = described_class.convert_date_to_text('28/02/2024')
        expect(result).to eq('vinte e oito de fevereiro de dois mil e vinte e quatro')
      end

      it 'converts a date in April' do
        result = described_class.convert_date_to_text('21/04/2024')
        expect(result).to eq('vinte e um de abril de dois mil e vinte e quatro')
      end

      it 'converts a date in June' do
        result = described_class.convert_date_to_text('15/06/2024')
        expect(result).to eq('quinze de junho de dois mil e vinte e quatro')
      end

      it 'converts a date in July' do
        result = described_class.convert_date_to_text('09/07/2024')
        expect(result).to eq('nove de julho de dois mil e vinte e quatro')
      end

      it 'converts a date in August' do
        result = described_class.convert_date_to_text('15/08/2024')
        expect(result).to eq('quinze de agosto de dois mil e vinte e quatro')
      end

      it 'converts a date in September' do
        result = described_class.convert_date_to_text('07/09/2024')
        expect(result).to eq('sete de setembro de dois mil e vinte e quatro')
      end

      it 'converts a date in October' do
        result = described_class.convert_date_to_text('12/10/2024')
        expect(result).to eq('doze de outubro de dois mil e vinte e quatro')
      end

      it 'converts a date in November' do
        result = described_class.convert_date_to_text('15/11/2024')
        expect(result).to eq('quinze de novembro de dois mil e vinte e quatro')
      end

      it 'converts last day of the year' do
        result = described_class.convert_date_to_text('31/12/2024')
        expect(result).to eq('trinta e um de dezembro de dois mil e vinte e quatro')
      end

      it 'converts a date with day 10' do
        result = described_class.convert_date_to_text('10/10/2024')
        expect(result).to eq('dez de outubro de dois mil e vinte e quatro')
      end

      it 'converts a date with day 11' do
        result = described_class.convert_date_to_text('11/11/2024')
        expect(result).to eq('onze de novembro de dois mil e vinte e quatro')
      end

      it 'converts a date with day 20' do
        result = described_class.convert_date_to_text('20/01/2024')
        expect(result).to eq('vinte de janeiro de dois mil e vinte e quatro')
      end

      it 'converts a date with day 30' do
        result = described_class.convert_date_to_text('30/04/2024')
        expect(result).to eq('trinta de abril de dois mil e vinte e quatro')
      end
    end

    context 'with an ISO yyyy-mm-dd string' do
      it 'parses and converts an ISO date' do
        result = described_class.convert_date_to_text('2024-12-25')
        expect(result).to eq('vinte e cinco de dezembro de dois mil e vinte e quatro')
      end
    end

    context 'with a Date/Time object' do
      it 'converts a Date' do
        expect(described_class.convert_date_to_text(Date.new(2024, 12, 25)))
          .to eq('vinte e cinco de dezembro de dois mil e vinte e quatro')
      end
    end

    context 'with different years' do
      it 'converts year 2000' do
        result = described_class.convert_date_to_text('01/01/2000')
        expect(result).to eq('primeiro de janeiro de dois mil')
      end

      it 'converts year 2023' do
        result = described_class.convert_date_to_text('15/05/2023')
        expect(result).to eq('quinze de maio de dois mil e vinte e três')
      end

      it 'converts year 2025' do
        result = described_class.convert_date_to_text('20/08/2025')
        expect(result).to eq('vinte de agosto de dois mil e vinte e cinco')
      end

      it 'converts year 1990' do
        result = described_class.convert_date_to_text('10/10/1990')
        expect(result).to eq('dez de outubro de mil novecentos e noventa')
      end
    end

    context 'with leap year dates' do
      it 'converts Feb 29 in a leap year' do
        result = described_class.convert_date_to_text('29/02/2024')
        expect(result).to eq('vinte e nove de fevereiro de dois mil e vinte e quatro')
      end
    end

    context 'with invalid dates' do
      it 'returns an empty string for invalid format (no slashes)' do
        result = described_class.convert_date_to_text('01012024')
        expect(result).to eq('')
      end

      it 'returns an empty string for invalid format (dashes instead of slashes)' do
        result = described_class.convert_date_to_text('01-01-2024')
        expect(result).to eq('')
      end

      it 'returns an empty string for invalid format (yyyy/mm/dd)' do
        result = described_class.convert_date_to_text('2024/01/01')
        expect(result).to eq('')
      end

      it 'returns an empty string for invalid day (32)' do
        result = described_class.convert_date_to_text('32/01/2024')
        expect(result).to eq('')
      end

      it 'returns an empty string for invalid day (00)' do
        result = described_class.convert_date_to_text('00/01/2024')
        expect(result).to eq('')
      end

      it 'returns an empty string for invalid month (13)' do
        result = described_class.convert_date_to_text('01/13/2024')
        expect(result).to eq('')
      end

      it 'returns an empty string for invalid month (00)' do
        result = described_class.convert_date_to_text('01/00/2024')
        expect(result).to eq('')
      end

      it 'returns an empty string for Feb 30' do
        result = described_class.convert_date_to_text('30/02/2024')
        expect(result).to eq('')
      end

      it 'returns an empty string for Feb 29 in non-leap year' do
        result = described_class.convert_date_to_text('29/02/2023')
        expect(result).to eq('')
      end

      it 'returns an empty string for nil input' do
        result = described_class.convert_date_to_text(nil)
        expect(result).to eq('')
      end

      it 'returns an empty string for empty string' do
        result = described_class.convert_date_to_text('')
        expect(result).to eq('')
      end

      it 'returns an empty string for non-string input' do
        result = described_class.convert_date_to_text(123)
        expect(result).to eq('')
      end

      it 'returns an empty string for incomplete date' do
        result = described_class.convert_date_to_text('01/01')
        expect(result).to eq('')
      end

      it 'returns an empty string for date with letters' do
        result = described_class.convert_date_to_text('01/ab/2024')
        expect(result).to eq('')
      end
    end
  end

  describe '.get_holidays' do
    it 'returns an array of holiday hashes for a valid year' do
      holidays = described_class.get_holidays(2024)
      expect(holidays).to be_an(Array)
      expect(holidays).not_to be_empty
      expect(holidays.first).to include(:name, :date, :type)
    end

    it 'sorts holidays by date' do
      holidays = described_class.get_holidays(2024)
      expect(holidays.map { |h| h[:date] }).to eq(holidays.map { |h| h[:date] }.sort)
    end

    it 'includes Dia da Consciência Negra as national from 2024' do
      holidays = described_class.get_holidays(2024)
      consciencia_negra = holidays.find { |h| h[:date] == Date.new(2024, 11, 20) }
      expect(consciencia_negra[:type]).to eq(:national)
    end

    it 'does not include Nov 20 as a national holiday before 2024' do
      holidays = described_class.get_holidays(2023)
      nov20 = holidays.find { |h| h[:date] == Date.new(2023, 11, 20) }
      expect(nov20).to be_nil
    end

    it 'includes Good Friday' do
      holidays = described_class.get_holidays(2024)
      expect(holidays.map { |h| h[:date] }).to include(Date.new(2024, 3, 29))
    end

    it 'includes Carnaval and Corpus Christi as optional' do
      holidays = described_class.get_holidays(2024)
      optional = holidays.select { |h| h[:type] == :optional }
      expect(optional.map { |h| h[:date] }).to include(Date.new(2024, 2, 13), Date.new(2024, 5, 30))
    end

    it 'includes Carnaval Monday (in addition to Carnaval Tuesday) as optional' do
      # Easter Sunday 2024 is March 31st (also implied by the "includes Good
      # Friday" example above, Easter - 2 = March 29th).
      easter = Date.new(2024, 3, 31)
      holidays = described_class.get_holidays(2024)
      optional = holidays.select { |h| h[:type] == :optional && h[:name] == 'Carnaval' }

      expect(optional.map { |h| h[:date] }).to contain_exactly(easter - 48, easter - 47)
      expect(easter - 48).to eq(Date.new(2024, 2, 12))
      expect(easter - 47).to eq(Date.new(2024, 2, 13))
    end

    it 'has 13 holidays for a year from 2024 onward (12 + Carnaval Monday)' do
      expect(described_class.get_holidays(2024).length).to eq(13)
    end

    it 'returns an empty array for an out-of-range year' do
      expect(described_class.get_holidays(1800)).to eq([])
      expect(described_class.get_holidays(2200)).to eq([])
    end

    it 'returns an empty array for a non-integer year' do
      expect(described_class.get_holidays('2024')).to eq([])
    end
  end

  describe '.is_business_day' do
    it 'returns true for a regular weekday' do
      expect(described_class.is_business_day(Date.new(2024, 3, 4))).to be true # Monday
    end

    it 'returns false for a Saturday' do
      expect(described_class.is_business_day(Date.new(2024, 3, 2))).to be false
    end

    it 'returns false for a Sunday' do
      expect(described_class.is_business_day(Date.new(2024, 3, 3))).to be false
    end

    it 'returns false for a national holiday' do
      expect(described_class.is_business_day(Date.new(2024, 1, 1))).to be false
    end

    it 'returns false for Good Friday' do
      expect(described_class.is_business_day(Date.new(2024, 3, 29))).to be false
    end

    it 'counts Carnaval by default' do
      expect(described_class.is_business_day(Date.new(2024, 2, 13))).to be false
    end

    it 'does not count Carnaval when optional: false' do
      expect(described_class.is_business_day(Date.new(2024, 2, 13), optional: false)).to be true
    end

    it 'returns false for a state holiday when that state is given' do
      expect(described_class.is_business_day(Date.new(2024, 7, 9), state: 'SP')).to be false
    end

    it 'returns false for an invalid date' do
      expect(described_class.is_business_day('not a date')).to be false
    end

    it 'has an alias .business_day?' do
      expect(described_class.business_day?(Date.new(2024, 3, 4))).to be true
    end
  end

  describe '.add_business_days' do
    it 'adds business days, skipping the weekend' do
      # Friday 2024-03-01 + 1 business day => Monday 2024-03-04
      result = described_class.add_business_days(Date.new(2024, 3, 1), 1)
      expect(result).to eq(Date.new(2024, 3, 4))
    end

    it 'returns the same date for amount 0' do
      result = described_class.add_business_days(Date.new(2024, 3, 2), 0)
      expect(result).to eq(Date.new(2024, 3, 2))
    end

    it 'walks backwards for a negative amount' do
      result = described_class.add_business_days(Date.new(2024, 3, 4), -1)
      expect(result).to eq(Date.new(2024, 3, 1))
    end

    it 'preserves the time of day for a Time input' do
      time = Time.new(2024, 3, 1, 10, 30, 0)
      result = described_class.add_business_days(time, 1)
      expect(result.hour).to eq(10)
      expect(result.min).to eq(30)
    end

    it 'returns nil for an invalid date' do
      expect(described_class.add_business_days('invalid', 1)).to be_nil
    end

    it 'returns nil for a non-integer amount' do
      expect(described_class.add_business_days(Date.new(2024, 3, 1), 1.5)).to be_nil
    end
  end

  describe '.sub_business_days' do
    it 'subtracts business days' do
      result = described_class.sub_business_days(Date.new(2024, 3, 4), 1)
      expect(result).to eq(Date.new(2024, 3, 1))
    end
  end

  describe '.difference_in_business_days' do
    it 'counts business days between two dates' do
      result = described_class.difference_in_business_days(Date.new(2024, 3, 4), Date.new(2024, 3, 1))
      expect(result).to eq(1)
    end

    it 'returns 0 for the same day' do
      result = described_class.difference_in_business_days(Date.new(2024, 3, 1), Date.new(2024, 3, 1))
      expect(result).to eq(0)
    end

    it 'is negative when laterDate precedes earlierDate' do
      result = described_class.difference_in_business_days(Date.new(2024, 3, 1), Date.new(2024, 3, 4))
      expect(result).to eq(-1)
    end

    it 'returns nil for an invalid date' do
      expect(described_class.difference_in_business_days('invalid', Date.new(2024, 3, 1))).to be_nil
    end
  end

  describe 'BrazilianUtils::Months' do
    describe '.name' do
      it 'returns janeiro for month 1' do
        expect(BrazilianUtils::Months.name(1)).to eq('janeiro')
      end

      it 'returns fevereiro for month 2' do
        expect(BrazilianUtils::Months.name(2)).to eq('fevereiro')
      end

      it 'returns março for month 3' do
        expect(BrazilianUtils::Months.name(3)).to eq('março')
      end

      it 'returns dezembro for month 12' do
        expect(BrazilianUtils::Months.name(12)).to eq('dezembro')
      end

      it 'returns nil for invalid month' do
        expect(BrazilianUtils::Months.name(13)).to be_nil
      end
    end
  end
end
