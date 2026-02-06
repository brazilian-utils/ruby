require_relative '../lib/brazilian-utils/date-utils'
require 'date'

puts "=" * 70
puts "Brazilian Date Utils - Usage Examples"
puts "=" * 70
puts

# ============================================================================
# Holiday Checking
# ============================================================================
puts "1. CHECKING NATIONAL HOLIDAYS"
puts "-" * 70

# New Year
new_year = Date.new(2024, 1, 1)
puts "New Year (Jan 1, 2024): #{BrazilianUtils::DateUtils.is_holiday(new_year)}"

# Christmas
christmas = Date.new(2024, 12, 25)
puts "Christmas (Dec 25, 2024): #{BrazilianUtils::DateUtils.is_holiday(christmas)}"

# Independence Day
independence = Date.new(2024, 9, 7)
puts "Independence Day (Sep 7, 2024): #{BrazilianUtils::DateUtils.is_holiday(independence)}"

# Labor Day
labor_day = Date.new(2024, 5, 1)
puts "Labor Day (May 1, 2024): #{BrazilianUtils::DateUtils.is_holiday(labor_day)}"

# Regular day
regular_day = Date.new(2024, 3, 15)
puts "Regular day (Mar 15, 2024): #{BrazilianUtils::DateUtils.is_holiday(regular_day)}"
puts

# ============================================================================
# State Holidays
# ============================================================================
puts "2. CHECKING STATE-SPECIFIC HOLIDAYS"
puts "-" * 70

# São Paulo state holiday (July 9)
sp_holiday = Date.new(2024, 7, 9)
puts "July 9, 2024 in São Paulo: #{BrazilianUtils::DateUtils.is_holiday(sp_holiday, 'SP')}"
puts "July 9, 2024 in Rio de Janeiro: #{BrazilianUtils::DateUtils.is_holiday(sp_holiday, 'RJ')}"
puts "July 9, 2024 in Minas Gerais: #{BrazilianUtils::DateUtils.is_holiday(sp_holiday, 'MG')}"
puts

# Rio de Janeiro state holiday (November 20 - Consciência Negra)
rj_holiday = Date.new(2024, 11, 20)
puts "November 20, 2024 in Rio de Janeiro: #{BrazilianUtils::DateUtils.is_holiday(rj_holiday, 'RJ')}"
puts "November 20, 2024 in São Paulo: #{BrazilianUtils::DateUtils.is_holiday(rj_holiday, 'SP')}"
puts "November 20, 2024 in Mato Grosso: #{BrazilianUtils::DateUtils.is_holiday(rj_holiday, 'MT')}"
puts

# Bahia state holiday (July 2)
ba_holiday = Date.new(2024, 7, 2)
puts "July 2, 2024 in Bahia: #{BrazilianUtils::DateUtils.is_holiday(ba_holiday, 'BA')}"
puts "July 2, 2024 in São Paulo: #{BrazilianUtils::DateUtils.is_holiday(ba_holiday, 'SP')}"
puts

# ============================================================================
# Testing Today
# ============================================================================
puts "3. CHECKING TODAY'S DATE"
puts "-" * 70

today = Date.today
puts "Today is: #{today.strftime('%d/%m/%Y')}"
puts "Is today a national holiday? #{BrazilianUtils::DateUtils.is_holiday(today)}"
puts "Is today a holiday in SP? #{BrazilianUtils::DateUtils.is_holiday(today, 'SP')}"
puts "Is today a holiday in RJ? #{BrazilianUtils::DateUtils.is_holiday(today, 'RJ')}"
puts

# ============================================================================
# Different Date Types
# ============================================================================
puts "4. TESTING DIFFERENT DATE TYPES"
puts "-" * 70

date_obj = Date.new(2024, 12, 25)
datetime_obj = DateTime.new(2024, 12, 25, 10, 30, 0)
time_obj = Time.new(2024, 12, 25, 10, 30, 0)

puts "Date object (Christmas): #{BrazilianUtils::DateUtils.is_holiday(date_obj)}"
puts "DateTime object (Christmas): #{BrazilianUtils::DateUtils.is_holiday(datetime_obj)}"
puts "Time object (Christmas): #{BrazilianUtils::DateUtils.is_holiday(time_obj)}"
puts

# ============================================================================
# Invalid Inputs
# ============================================================================
puts "5. TESTING INVALID INPUTS"
puts "-" * 70

puts "String date '2024-01-01': #{BrazilianUtils::DateUtils.is_holiday('2024-01-01').inspect}"
puts "Invalid UF 'XX': #{BrazilianUtils::DateUtils.is_holiday(Date.new(2024, 1, 1), 'XX').inspect}"
puts "Invalid UF 'Invalid': #{BrazilianUtils::DateUtils.is_holiday(Date.new(2024, 1, 1), 'Invalid').inspect}"
puts

# ============================================================================
# Date to Text Conversion
# ============================================================================
puts "6. CONVERTING DATES TO TEXT"
puts "-" * 70

# Regular dates
date1 = '15/03/2024'
puts "#{date1}: #{BrazilianUtils::DateUtils.convert_date_to_text(date1)}"

date2 = '25/12/2023'
puts "#{date2}: #{BrazilianUtils::DateUtils.convert_date_to_text(date2)}"

# First day of month (special case using "Primeiro")
date3 = '01/01/2024'
puts "#{date3}: #{BrazilianUtils::DateUtils.convert_date_to_text(date3)}"

date4 = '01/05/2024'
puts "#{date4}: #{BrazilianUtils::DateUtils.convert_date_to_text(date4)}"

# Different months
date5 = '21/04/2024'
puts "#{date5}: #{BrazilianUtils::DateUtils.convert_date_to_text(date5)}"

date6 = '07/09/2024'
puts "#{date6}: #{BrazilianUtils::DateUtils.convert_date_to_text(date6)}"
puts

# ============================================================================
# Brazilian National Holidays in Text
# ============================================================================
puts "7. BRAZILIAN NATIONAL HOLIDAYS IN TEXT FORMAT"
puts "-" * 70

national_holidays = [
  '01/01/2024',  # New Year
  '21/04/2024',  # Tiradentes
  '01/05/2024',  # Labor Day
  '07/09/2024',  # Independence Day
  '12/10/2024',  # Nossa Senhora Aparecida
  '02/11/2024',  # All Souls Day
  '15/11/2024',  # Proclamation of the Republic
  '25/12/2024'   # Christmas
]

national_holidays.each do |holiday|
  text = BrazilianUtils::DateUtils.convert_date_to_text(holiday)
  puts "#{holiday}: #{text}"
end
puts

# ============================================================================
# Invalid Date Conversions
# ============================================================================
puts "8. TESTING INVALID DATE CONVERSIONS"
puts "-" * 70

invalid_dates = [
  '32/01/2024',    # Invalid day
  '29/02/2023',    # Not a leap year
  '01-01-2024',    # Wrong separator
  '2024/01/01',    # Wrong format
  '00/01/2024',    # Day zero
  '01/13/2024',    # Invalid month
  'invalid',       # Non-date string
  ''               # Empty string
]

invalid_dates.each do |date|
  result = BrazilianUtils::DateUtils.convert_date_to_text(date)
  puts "#{date.inspect}: #{result.inspect}"
end
puts

# ============================================================================
# Practical Use Case: Document Date
# ============================================================================
puts "9. PRACTICAL USE CASE: DOCUMENT FORMATTING"
puts "-" * 70

document_date = '15/03/2024'
formatted_date = BrazilianUtils::DateUtils.convert_date_to_text(document_date)

puts "Contract Template:"
puts "-" * 70
puts "Contrato celebrado em São Paulo, aos #{formatted_date}."
puts
puts "Invoice Template:"
puts "-" * 70
puts "Nota Fiscal emitida em: #{formatted_date.capitalize}"
puts

# ============================================================================
# Checking Multiple States
# ============================================================================
puts "10. CHECKING HOLIDAYS ACROSS ALL STATES"
puts "-" * 70

test_date = Date.new(2024, 11, 20)  # Consciência Negra
states = %w[SP RJ MG BA RS PR SC PE CE GO DF]

puts "Date: November 20, 2024 (Consciência Negra)"
puts "Holiday Status by State:"
states.each do |state|
  is_holiday = BrazilianUtils::DateUtils.is_holiday(test_date, state)
  status = is_holiday ? "✓ Holiday" : "✗ Not a holiday"
  puts "  #{state}: #{status}"
end
puts

# ============================================================================
# Leap Year Handling
# ============================================================================
puts "11. LEAP YEAR DATE HANDLING"
puts "-" * 70

leap_date = '29/02/2024'
non_leap_date = '29/02/2023'

puts "#{leap_date}: #{BrazilianUtils::DateUtils.convert_date_to_text(leap_date)}"
puts "#{non_leap_date}: #{BrazilianUtils::DateUtils.convert_date_to_text(non_leap_date).inspect} (invalid)"
puts

# ============================================================================
# Combined Example: Check Holiday and Convert to Text
# ============================================================================
puts "12. COMBINED EXAMPLE: HOLIDAY CHECK + TEXT CONVERSION"
puts "-" * 70

def format_holiday_info(date_str, uf = nil)
  begin
    day, month, year = date_str.split('/').map(&:to_i)
    date_obj = Date.new(year, month, day)
    
    is_holiday = BrazilianUtils::DateUtils.is_holiday(date_obj, uf)
    text = BrazilianUtils::DateUtils.convert_date_to_text(date_str)
    
    puts "Data: #{date_str}"
    puts "Por extenso: #{text}"
    if uf
      puts "Feriado em #{uf}? #{is_holiday ? 'Sim' : 'Não'}"
    else
      puts "Feriado nacional? #{is_holiday ? 'Sim' : 'Não'}"
    end
    puts
  rescue => e
    puts "Erro ao processar #{date_str}: #{e.message}"
    puts
  end
end

format_holiday_info('25/12/2024')
format_holiday_info('09/07/2024', 'SP')
format_holiday_info('15/03/2024')
format_holiday_info('01/01/2024', 'RJ')

puts "=" * 70
puts "Examples completed!"
puts "=" * 70
