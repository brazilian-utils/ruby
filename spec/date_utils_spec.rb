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
      it 'returns nil for invalid date object' do
        expect(described_class.is_holiday('2024-01-01')).to be_nil
      end

      it 'returns nil for nil date' do
        expect(described_class.is_holiday(nil)).to be_nil
      end

      it 'returns nil for invalid UF' do
        date = Date.new(2024, 1, 1)
        expect(described_class.is_holiday(date, 'XX')).to be_nil
      end

      it 'returns nil for invalid UF format' do
        date = Date.new(2024, 1, 1)
        expect(described_class.is_holiday(date, 'Invalid')).to be_nil
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
        expect(result).to eq('Primeiro de janeiro de dois mil e vinte e quatro')
      end

      it 'converts a date with day 1' do
        result = described_class.convert_date_to_text('01/05/2024')
        expect(result).to eq('Primeiro de maio de dois mil e vinte e quatro')
      end

      it 'converts a regular date' do
        result = described_class.convert_date_to_text('15/03/2024')
        expect(result).to eq('Quinze de março de dois mil e vinte e quatro')
      end

      it 'converts a date with two-digit day' do
        result = described_class.convert_date_to_text('25/12/2023')
        expect(result).to eq('Vinte e cinco de dezembro de dois mil e vinte e três')
      end

      it 'converts a date in February' do
        result = described_class.convert_date_to_text('28/02/2024')
        expect(result).to eq('Vinte e oito de fevereiro de dois mil e vinte e quatro')
      end

      it 'converts a date in April' do
        result = described_class.convert_date_to_text('21/04/2024')
        expect(result).to eq('Vinte e um de abril de dois mil e vinte e quatro')
      end

      it 'converts a date in June' do
        result = described_class.convert_date_to_text('15/06/2024')
        expect(result).to eq('Quinze de junho de dois mil e vinte e quatro')
      end

      it 'converts a date in July' do
        result = described_class.convert_date_to_text('09/07/2024')
        expect(result).to eq('Nove de julho de dois mil e vinte e quatro')
      end

      it 'converts a date in August' do
        result = described_class.convert_date_to_text('15/08/2024')
        expect(result).to eq('Quinze de agosto de dois mil e vinte e quatro')
      end

      it 'converts a date in September' do
        result = described_class.convert_date_to_text('07/09/2024')
        expect(result).to eq('Sete de setembro de dois mil e vinte e quatro')
      end

      it 'converts a date in October' do
        result = described_class.convert_date_to_text('12/10/2024')
        expect(result).to eq('Doze de outubro de dois mil e vinte e quatro')
      end

      it 'converts a date in November' do
        result = described_class.convert_date_to_text('15/11/2024')
        expect(result).to eq('Quinze de novembro de dois mil e vinte e quatro')
      end

      it 'converts last day of the year' do
        result = described_class.convert_date_to_text('31/12/2024')
        expect(result).to eq('Trinta e um de dezembro de dois mil e vinte e quatro')
      end

      it 'converts a date with day 10' do
        result = described_class.convert_date_to_text('10/10/2024')
        expect(result).to eq('Dez de outubro de dois mil e vinte e quatro')
      end

      it 'converts a date with day 11' do
        result = described_class.convert_date_to_text('11/11/2024')
        expect(result).to eq('Onze de novembro de dois mil e vinte e quatro')
      end

      it 'converts a date with day 20' do
        result = described_class.convert_date_to_text('20/01/2024')
        expect(result).to eq('Vinte de janeiro de dois mil e vinte e quatro')
      end

      it 'converts a date with day 30' do
        result = described_class.convert_date_to_text('30/04/2024')
        expect(result).to eq('Trinta de abril de dois mil e vinte e quatro')
      end
    end

    context 'with different years' do
      it 'converts year 2000' do
        result = described_class.convert_date_to_text('01/01/2000')
        expect(result).to eq('Primeiro de janeiro de dois mil')
      end

      it 'converts year 2023' do
        result = described_class.convert_date_to_text('15/05/2023')
        expect(result).to eq('Quinze de maio de dois mil e vinte e três')
      end

      it 'converts year 2025' do
        result = described_class.convert_date_to_text('20/08/2025')
        expect(result).to eq('Vinte de agosto de dois mil e vinte e cinco')
      end

      it 'converts year 1990' do
        result = described_class.convert_date_to_text('10/10/1990')
        expect(result).to eq('Dez de outubro de mil novecentos e noventa')
      end
    end

    context 'with leap year dates' do
      it 'converts Feb 29 in a leap year' do
        result = described_class.convert_date_to_text('29/02/2024')
        expect(result).to eq('Vinte e nove de fevereiro de dois mil e vinte e quatro')
      end
    end

    context 'with invalid dates' do
      it 'returns nil for invalid format (no slashes)' do
        result = described_class.convert_date_to_text('01012024')
        expect(result).to be_nil
      end

      it 'returns nil for invalid format (dashes instead of slashes)' do
        result = described_class.convert_date_to_text('01-01-2024')
        expect(result).to be_nil
      end

      it 'returns nil for invalid format (yyyy/mm/dd)' do
        result = described_class.convert_date_to_text('2024/01/01')
        expect(result).to be_nil
      end

      it 'returns nil for invalid day (32)' do
        result = described_class.convert_date_to_text('32/01/2024')
        expect(result).to be_nil
      end

      it 'returns nil for invalid day (00)' do
        result = described_class.convert_date_to_text('00/01/2024')
        expect(result).to be_nil
      end

      it 'returns nil for invalid month (13)' do
        result = described_class.convert_date_to_text('01/13/2024')
        expect(result).to be_nil
      end

      it 'returns nil for invalid month (00)' do
        result = described_class.convert_date_to_text('01/00/2024')
        expect(result).to be_nil
      end

      it 'returns nil for Feb 30' do
        result = described_class.convert_date_to_text('30/02/2024')
        expect(result).to be_nil
      end

      it 'returns nil for Feb 29 in non-leap year' do
        result = described_class.convert_date_to_text('29/02/2023')
        expect(result).to be_nil
      end

      it 'returns nil for nil input' do
        result = described_class.convert_date_to_text(nil)
        expect(result).to be_nil
      end

      it 'returns nil for empty string' do
        result = described_class.convert_date_to_text('')
        expect(result).to be_nil
      end

      it 'returns nil for non-string input' do
        result = described_class.convert_date_to_text(123)
        expect(result).to be_nil
      end

      it 'returns nil for incomplete date' do
        result = described_class.convert_date_to_text('01/01')
        expect(result).to be_nil
      end

      it 'returns nil for date with letters' do
        result = described_class.convert_date_to_text('01/ab/2024')
        expect(result).to be_nil
      end
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
