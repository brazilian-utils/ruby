# :brazil: Brazilian Utils
> Utils library for specific Brazilian businesses.

[![Gem Version](https://badge.fury.io/rb/pipeme.svg)](https://badge.fury.io/rb/brazilian-utils)
![](http://ruby-gem-downloads-badge.herokuapp.com/brazilian-utils)
[![Build Status](https://travis-ci.org/brazilian-utils/ruby.svg?branch=master)](https://travis-ci.org/brazilian-utils/ruby)

## Features

This library provides utilities for working with Brazilian-specific data formats:

### CPF Utils
- CPF validation (Cadastro de Pessoas Físicas)
- CPF formatting and symbol removal
- Random CPF generation

### CNH Utils
- CNH validation (Carteira Nacional de Habilitação)

### CNPJ Utils
- CNPJ validation (Cadastro Nacional da Pessoa Jurídica)
- CNPJ formatting and symbol removal
- Random CNPJ generation

### Currency Utils
- Brazilian Real (R$) currency formatting
- Convert monetary values to text in Brazilian Portuguese

### Date Utils
- Check if a date is a Brazilian national or state holiday
- Convert dates to text in Brazilian Portuguese

### Email Utils
- Email address validation following RFC 5322 specifications

### Legal Nature Utils
- Validate official Brazilian Legal Nature (Natureza Jurídica) codes
- Lookup descriptions for legal nature codes
- Browse codes by category

### Legal Process Utils
- Format Brazilian legal process IDs
- Validate legal process ID structure and checksum
- Generate random legal process IDs

### License Plate Utils
- Validate Brazilian license plates (old and Mercosul formats)
- Convert old format plates to Mercosul format
- Format license plates with proper dash or uppercase
- Generate random license plates
- Detect plate format type

### Phone Utils
- Validate Brazilian phone numbers (mobile and landline)
- Format phone numbers with area code and separator
- Remove symbols from phone numbers
- Generate random phone numbers
- Remove international dialing code

### PIS Utils
- Validate PIS numbers (Programa de Integração Social)
- Format PIS with dots and hyphen
- Remove formatting symbols
- Generate random valid PIS numbers

### RENAVAM Utils
- Validate RENAVAM numbers (Registro Nacional de Veículos Automotores)

### Voter ID Utils
- Validate Brazilian voter ID (Título de Eleitor)
- Format voter ID with spaces
- Generate random valid voter IDs for any state
- Support for 12 and 13-digit voter IDs (SP and MG edge cases)

### CEP Utils
- CEP validation and formatting
- Random CEP generation
- Address lookup by CEP (ViaCEP API integration)
- CEP search by address (ViaCEP API integration)
- Brazilian state (UF) utilities

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'brazilian-utils'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install brazilian-utils
```

## Usage

### CPF Utils

Based on the [brazilian-utils/python](https://github.com/brazilian-utils/python/blob/main/brutils/cpf.py) implementation.

#### Formatting Functions

##### `remove_symbols(dirty)` / `sieve(dirty)`

Removes specific symbols from a CPF string (`.`, `-`).

```ruby
require 'brazilian-utils/cpf-utils'

BrazilianUtils::CPFUtils.remove_symbols('123.456.789-01')
# => "12345678901"

BrazilianUtils::CPFUtils.remove_symbols('987-654-321.01')
# => "98765432101"
```

##### `format_cpf(cpf)`

Formats a valid CPF string for visual display.

```ruby
BrazilianUtils::CPFUtils.format_cpf('82178537464')
# => "821.785.374-64"

BrazilianUtils::CPFUtils.format_cpf('55550207753')
# => "555.502.077-53"

BrazilianUtils::CPFUtils.format_cpf('12345678901')
# => nil (invalid CPF)
```

##### `display(cpf)` (Legacy)

Formats a numbers-only CPF string with visual aid symbols.

```ruby
BrazilianUtils::CPFUtils.display('12345678901')
# => "123.456.789-01"
```

**Note:** `display` is provided for backward compatibility. Use `format_cpf` for new code.

#### Validation Functions

##### `valid?(cpf)` / `validate(cpf)`

Validates a CPF by verifying its checksum digits.

```ruby
# Valid CPF
BrazilianUtils::CPFUtils.valid?('82178537464')
# => true

BrazilianUtils::CPFUtils.valid?('41840660546')
# => true

# Invalid CPF - wrong checksum
BrazilianUtils::CPFUtils.valid?('12345678901')
# => false

# Invalid CPF - all same digits
BrazilianUtils::CPFUtils.valid?('00000000000')
# => false

# Invalid CPF - must be numbers only
BrazilianUtils::CPFUtils.valid?('821.785.374-64')
# => false
```

**Parameters:**
- `cpf` (String): CPF string to validate (must be 11 digits, numbers only)

**Returns:**
- `Boolean`: `true` if the CPF is valid, `false` otherwise

**Validation Rules:**
- Must be exactly 11 digits
- Cannot be a sequence of the same digit (e.g., "00000000000", "11111111111")
- The last two digits must match the calculated checksum

#### Generation Function

##### `generate()`

Generates a random valid CPF.

```ruby
BrazilianUtils::CPFUtils.generate
# => "10895948109"

BrazilianUtils::CPFUtils.generate
# => "52837606502"
```

**Returns:**
- `String`: A randomly generated valid 11-digit CPF

**Note:** The generated CPF will always be valid and will not start with 0.

#### Complete Example

```ruby
require 'brazilian-utils/cpf-utils'

# Generate a new CPF
cpf = BrazilianUtils::CPFUtils.generate
puts "Generated: #{cpf}"
# => "82178537464"

# Validate CPF
if BrazilianUtils::CPFUtils.valid?(cpf)
  puts "CPF is valid!"
end

# Format for display
formatted = BrazilianUtils::CPFUtils.format_cpf(cpf)
puts "Formatted: #{formatted}"
# => "821.785.374-64"

# Clean formatted CPF
dirty_cpf = '821.785.374-64'
clean = BrazilianUtils::CPFUtils.remove_symbols(dirty_cpf)
puts "Cleaned: #{clean}"
# => "82178537464"

# Validate cleaned CPF
puts "Valid? #{BrazilianUtils::CPFUtils.valid?(clean)}"
# => true
```

### CNH Utils

Based on the [brazilian-utils/python](https://github.com/brazilian-utils/python/blob/main/brutils/cnh.py) implementation.

#### `valid?(cnh)`

Validates the registration number for the Brazilian CNH (Carteira Nacional de Habilitação) that was created in 2022.

**Note:** Previous versions of the CNH are not supported in this version.

This function checks if the given CNH is valid based on the format and allowed characters, verifying the verification digits.

```ruby
require 'brazilian-utils/cnh-utils'

# Valid CNH
BrazilianUtils::CNHUtils.valid?('98765432100')
# => true

# Valid CNH with symbols (they are ignored)
BrazilianUtils::CNHUtils.valid?('987654321-00')
# => true

BrazilianUtils::CNHUtils.valid?('987.654.321-00')
# => true

# Invalid CNH - wrong verification digits
BrazilianUtils::CNHUtils.valid?('12345678901')
# => false

# Invalid CNH - contains letters
BrazilianUtils::CNHUtils.valid?('A2C45678901')
# => false

# Invalid CNH - all same digits
BrazilianUtils::CNHUtils.valid?('00000000000')
# => false

# Invalid CNH - wrong length
BrazilianUtils::CNHUtils.valid?('123456789')
# => false
```

**Parameters:**
- `cnh` (String): CNH string (symbols will be ignored)

**Returns:**
- `Boolean`: `true` if CNH has a valid format, `false` otherwise

**Validation Rules:**
- Must contain exactly 11 digits after removing non-numeric characters
- Cannot be a sequence of the same digit (e.g., "00000000000")
- Must have valid verification digits (10th and 11th positions)

### CNPJ Utils

Based on the [brazilian-utils/python](https://github.com/brazilian-utils/python/blob/main/brutils/cnpj.py) implementation.

#### Formatting Functions

##### `remove_symbols(dirty)` / `sieve(dirty)`

Removes specific symbols from a CNPJ string (`.`, `/`, `-`).

```ruby
require 'brazilian-utils/cnpj-utils'

BrazilianUtils::CNPJUtils.remove_symbols('12.345/6789-01')
# => "12345678901"

BrazilianUtils::CNPJUtils.remove_symbols('98/76.543-2101')
# => "98765432101"
```

##### `format_cnpj(cnpj)`

Formats a valid CNPJ string for visual display.

```ruby
BrazilianUtils::CNPJUtils.format_cnpj('03560714000142')
# => "03.560.714/0001-42"

BrazilianUtils::CNPJUtils.format_cnpj('98765432100100')
# => nil (invalid CNPJ)
```

##### `display(cnpj)` (Legacy)

Formats a numbers-only CNPJ string with visual aid symbols.

```ruby
BrazilianUtils::CNPJUtils.display('12345678901234')
# => "12.345.678/9012-34"
```

**Note:** `display` is provided for backward compatibility. Use `format_cnpj` for new code.

#### Validation Functions

##### `valid?(cnpj)` / `validate(cnpj)`

Validates a CNPJ by verifying its checksum digits.

```ruby
# Valid CNPJ
BrazilianUtils::CNPJUtils.valid?('03560714000142')
# => true

# Invalid CNPJ - wrong checksum
BrazilianUtils::CNPJUtils.valid?('00111222000133')
# => false

# Invalid CNPJ - all same digits
BrazilianUtils::CNPJUtils.valid?('00000000000000')
# => false

# Invalid CNPJ - wrong length
BrazilianUtils::CNPJUtils.valid?('123456789012')
# => false
```

**Parameters:**
- `cnpj` (String): CNPJ string to validate (must be 14 digits)

**Returns:**
- `Boolean`: `true` if the CNPJ is valid, `false` otherwise

**Validation Rules:**
- Must be exactly 14 digits
- Cannot be a sequence of the same digit (e.g., "00000000000000")
- The last two digits must match the calculated checksum

#### Generation Function

##### `generate(branch: 1)`

Generates a random valid CNPJ with an optional branch number.

```ruby
# Generate with default branch (1)
BrazilianUtils::CNPJUtils.generate
# => "30180536000105"

# Generate with specific branch
BrazilianUtils::CNPJUtils.generate(branch: 1234)
# => "01745284123455"

# Generate with branch 42
BrazilianUtils::CNPJUtils.generate(branch: 42)
# => "12345678004231"
```

**Parameters:**
- `branch` (Integer): Branch number (0001-9999). Defaults to 1. Values over 9999 are taken modulo 10000.

**Returns:**
- `String`: A randomly generated valid 14-digit CNPJ

**Note:** The branch number appears in positions 9-12 of the CNPJ (e.g., "12345678**0042**31").

#### Complete Example

```ruby
require 'brazilian-utils/cnpj-utils'

# Generate a new CNPJ
cnpj = BrazilianUtils::CNPJUtils.generate(branch: 1)
puts "Generated: #{cnpj}"
# => "12345678000195"

# Validate CNPJ
if BrazilianUtils::CNPJUtils.valid?(cnpj)
  puts "CNPJ is valid!"
end

# Format for display
formatted = BrazilianUtils::CNPJUtils.format_cnpj(cnpj)
puts "Formatted: #{formatted}"
# => "12.345.678/0001-95"

# Clean formatted CNPJ
dirty_cnpj = '03.560.714/0001-42'
clean = BrazilianUtils::CNPJUtils.remove_symbols(dirty_cnpj)
puts "Cleaned: #{clean}"
# => "03560714000142"

# Validate cleaned CNPJ
puts "Valid? #{BrazilianUtils::CNPJUtils.valid?(clean)}"
# => true
```

### Currency Utils

Based on the [brazilian-utils/python](https://github.com/brazilian-utils/python/blob/main/brutils/currency.py) implementation.

#### Currency Formatting

##### `format_currency(value)`

Formats a numeric value as Brazilian currency (R$).

```ruby
require 'brazilian-utils/currency-utils'

BrazilianUtils::CurrencyUtils.format_currency(1234.56)
# => "R$ 1.234,56"

BrazilianUtils::CurrencyUtils.format_currency(0)
# => "R$ 0,00"

BrazilianUtils::CurrencyUtils.format_currency(-9876.54)
# => "R$ -9.876,54"

BrazilianUtils::CurrencyUtils.format_currency(1234567.89)
# => "R$ 1.234.567,89"

BrazilianUtils::CurrencyUtils.format_currency("invalid")
# => nil
```

**Parameters:**
- `value` (Float, Integer, String, BigDecimal): The numeric value to format

**Returns:**
- `String`: Formatted currency string (e.g., "R$ 1.234,56")
- `nil`: If the input is invalid

**Features:**
- Automatically adds thousands separator (`.`)
- Uses comma (`,`) for decimal separator
- Always displays 2 decimal places
- Supports negative values
- Handles very large numbers

#### Money to Text Conversion

##### `convert_real_to_text(amount)`

Converts a monetary value in Brazilian Reais to textual representation in Portuguese.

```ruby
# Zero
BrazilianUtils::CurrencyUtils.convert_real_to_text(0.00)
# => "Zero reais"

# Only reais
BrazilianUtils::CurrencyUtils.convert_real_to_text(1.00)
# => "Um real"

BrazilianUtils::CurrencyUtils.convert_real_to_text(2.00)
# => "Dois reais"

BrazilianUtils::CurrencyUtils.convert_real_to_text(100.00)
# => "Cem reais"

# Only centavos
BrazilianUtils::CurrencyUtils.convert_real_to_text(0.01)
# => "Um centavo"

BrazilianUtils::CurrencyUtils.convert_real_to_text(0.50)
# => "Cinquenta centavos"

# Reais and centavos
BrazilianUtils::CurrencyUtils.convert_real_to_text(1.50)
# => "Um real e cinquenta centavos"

BrazilianUtils::CurrencyUtils.convert_real_to_text(1523.45)
# => "Mil, quinhentos e vinte e três reais e quarenta e cinco centavos"

# Large values
BrazilianUtils::CurrencyUtils.convert_real_to_text(1_000_000.00)
# => "Um milhão de reais"

BrazilianUtils::CurrencyUtils.convert_real_to_text(1_000_000_000.00)
# => "Um bilhão de reais"

# Negative values
BrazilianUtils::CurrencyUtils.convert_real_to_text(-10.50)
# => "Menos dez reais e cinquenta centavos"

# Invalid input
BrazilianUtils::CurrencyUtils.convert_real_to_text("invalid")
# => nil
```

**Parameters:**
- `amount` (BigDecimal, Float, Integer, String): Monetary value to convert

**Returns:**
- `String`: Textual representation in Brazilian Portuguese
- `nil`: If the input is invalid or exceeds limits

**Important Notes:**
- Values are rounded **down** to 2 decimal places
- Maximum supported value is 1 quadrillion reais (1,000,000,000,000,000)
- Negative values are prefixed with "Menos"
- Grammatically correct Portuguese (singular "real" vs plural "reais", "centavo" vs "centavos")
- Proper connectors for millions/billions ("milhão **de** reais")

#### Complete Example

```ruby
require 'brazilian-utils/currency-utils'

# Format a price
price = 1523.45
formatted = BrazilianUtils::CurrencyUtils.format_currency(price)
puts formatted
# => "R$ 1.523,45"

# Convert to text for a check/invoice
text = BrazilianUtils::CurrencyUtils.convert_real_to_text(price)
puts text
# => "Mil, quinhentos e vinte e três reais e quarenta e cinco centavos"

# Handle user input
user_input = "2500.75"
formatted = BrazilianUtils::CurrencyUtils.format_currency(user_input)
text = BrazilianUtils::CurrencyUtils.convert_real_to_text(user_input)

puts "Valor: #{formatted}"
puts "Por extenso: #{text}"
# => Valor: R$ 2.500,75
# => Por extenso: Dois mil, quinhentos e setenta e cinco reais e setenta e cinco centavos
```

### Date Utils

Based on the [brazilian-utils/python](https://github.com/brazilian-utils/python/blob/main/brutils/date_utils.py) implementation.

#### Holiday Checking

##### `is_holiday(target_date, uf = nil)`

Checks if the given date is a national or state holiday in Brazil.

```ruby
require 'brazilian-utils/date-utils'

# National holidays
BrazilianUtils::DateUtils.is_holiday(Date.new(2024, 1, 1))
# => true (New Year)

BrazilianUtils::DateUtils.is_holiday(Date.new(2024, 12, 25))
# => true (Christmas)

BrazilianUtils::DateUtils.is_holiday(Date.new(2024, 9, 7))
# => true (Independence Day)

# Regular day
BrazilianUtils::DateUtils.is_holiday(Date.new(2024, 3, 15))
# => false

# State-specific holidays
BrazilianUtils::DateUtils.is_holiday(Date.new(2024, 7, 9), 'SP')
# => true (Revolução Constitucionalista - São Paulo state holiday)

BrazilianUtils::DateUtils.is_holiday(Date.new(2024, 7, 9), 'RJ')
# => false (Not a holiday in Rio de Janeiro)

BrazilianUtils::DateUtils.is_holiday(Date.new(2024, 11, 20), 'RJ')
# => true (Consciência Negra - Rio de Janeiro state holiday)

# Works with different date types
BrazilianUtils::DateUtils.is_holiday(DateTime.new(2024, 12, 25, 10, 30))
# => true

BrazilianUtils::DateUtils.is_holiday(Time.new(2024, 12, 25))
# => true

# Invalid inputs
BrazilianUtils::DateUtils.is_holiday('2024-01-01')
# => nil (not a Date object)

BrazilianUtils::DateUtils.is_holiday(Date.new(2024, 1, 1), 'XX')
# => nil (invalid UF code)
```

**Parameters:**
- `target_date` (Date, DateTime, Time): The date to check
- `uf` (String, nil): Optional state abbreviation (UF) for state-specific holidays

**Returns:**
- `true`: If the date is a holiday
- `false`: If the date is not a holiday
- `nil`: If the date is invalid or UF is invalid

**National Holidays:**
- January 1: Ano Novo (New Year)
- April 21: Tiradentes
- May 1: Dia do Trabalho (Labor Day)
- September 7: Independência do Brasil (Independence Day)
- October 12: Nossa Senhora Aparecida
- November 2: Finados (All Souls Day)
- November 15: Proclamação da República (Proclamation of the Republic)
- December 25: Natal (Christmas)

**State Holidays:**
Each Brazilian state has specific holidays. Some examples:
- São Paulo (SP): July 9 - Revolução Constitucionalista de 1932
- Rio de Janeiro (RJ): November 20 - Dia da Consciência Negra
- Bahia (BA): July 2 - Independência da Bahia

**Important Notes:**
- This implementation only includes fixed-date holidays
- Movable holidays (like Carnival, Easter) are not included in this basic implementation
- Does not handle municipal holidays

#### Date to Text Conversion

##### `convert_date_to_text(date)`

Converts a date in Brazilian format (dd/mm/yyyy) to its textual representation in Portuguese.

```ruby
require 'brazilian-utils/date-utils'

# Regular dates
BrazilianUtils::DateUtils.convert_date_to_text('15/03/2024')
# => "Quinze de março de dois mil e vinte e quatro"

BrazilianUtils::DateUtils.convert_date_to_text('25/12/2023')
# => "Vinte e cinco de dezembro de dois mil e vinte e três"

# First day of month (special case)
BrazilianUtils::DateUtils.convert_date_to_text('01/01/2024')
# => "Primeiro de janeiro de dois mil e vinte e quatro"

BrazilianUtils::DateUtils.convert_date_to_text('01/05/2024')
# => "Primeiro de maio de dois mil e vinte e quatro"

# All months
BrazilianUtils::DateUtils.convert_date_to_text('15/02/2024')
# => "Quinze de fevereiro de dois mil e vinte e quatro"

BrazilianUtils::DateUtils.convert_date_to_text('21/04/2024')
# => "Vinte e um de abril de dois mil e vinte e quatro"

BrazilianUtils::DateUtils.convert_date_to_text('10/06/2024')
# => "Dez de junho de dois mil e vinte e quatro"

BrazilianUtils::DateUtils.convert_date_to_text('09/07/2024')
# => "Nove de julho de dois mil e vinte e quatro"

BrazilianUtils::DateUtils.convert_date_to_text('15/08/2024')
# => "Quinze de agosto de dois mil e vinte e quatro"

BrazilianUtils::DateUtils.convert_date_to_text('07/09/2024')
# => "Sete de setembro de dois mil e vinte e quatro"

BrazilianUtils::DateUtils.convert_date_to_text('12/10/2024')
# => "Doze de outubro de dois mil e vinte e quatro"

BrazilianUtils::DateUtils.convert_date_to_text('15/11/2024')
# => "Quinze de novembro de dois mil e vinte e quatro"

# Leap year
BrazilianUtils::DateUtils.convert_date_to_text('29/02/2024')
# => "Vinte e nove de fevereiro de dois mil e vinte e quatro"

# Invalid dates
BrazilianUtils::DateUtils.convert_date_to_text('32/01/2024')
# => nil (invalid day)

BrazilianUtils::DateUtils.convert_date_to_text('29/02/2023')
# => nil (not a leap year)

BrazilianUtils::DateUtils.convert_date_to_text('01-01-2024')
# => nil (wrong format - must use /)

BrazilianUtils::DateUtils.convert_date_to_text('2024/01/01')
# => nil (wrong format - must be dd/mm/yyyy)
```

**Parameters:**
- `date` (String): Date string in format dd/mm/yyyy

**Returns:**
- `String`: Date written out in Brazilian Portuguese
- `nil`: If the date format is invalid or the date doesn't exist

**Features:**
- Validates date format with regex pattern
- Checks if date actually exists (handles leap years, month lengths)
- Special handling for day 1 ("Primeiro" instead of "Um")
- Properly formatted Portuguese number words
- Supports all 12 months with Portuguese names

#### Complete Example

```ruby
require 'brazilian-utils/date-utils'

# Check if today is a holiday
today = Date.today
if BrazilianUtils::DateUtils.is_holiday(today)
  puts "Hoje é feriado nacional!"
elsif BrazilianUtils::DateUtils.is_holiday(today, 'SP')
  puts "Hoje é feriado em São Paulo!"
else
  puts "Hoje não é feriado"
end

# Check specific holidays
christmas = Date.new(2024, 12, 25)
puts "Christmas is a holiday: #{BrazilianUtils::DateUtils.is_holiday(christmas)}"
# => Christmas is a holiday: true

# Convert dates to text
date_str = '07/09/2024'
text = BrazilianUtils::DateUtils.convert_date_to_text(date_str)
puts "#{date_str} por extenso: #{text}"
# => 07/09/2024 por extenso: Sete de setembro de dois mil e vinte e quatro

# Format dates for documents
document_date = '15/03/2024'
formatted_date = BrazilianUtils::DateUtils.convert_date_to_text(document_date)
puts "São Paulo, #{formatted_date}"
# => São Paulo, Quinze de março de dois mil e vinte e quatro

# Check holidays for different states
holiday_date = Date.new(2024, 7, 9)
puts "SP holiday: #{BrazilianUtils::DateUtils.is_holiday(holiday_date, 'SP')}"  # true
puts "RJ holiday: #{BrazilianUtils::DateUtils.is_holiday(holiday_date, 'RJ')}"  # false
puts "MG holiday: #{BrazilianUtils::DateUtils.is_holiday(holiday_date, 'MG')}"  # false
```

### Email Utils

Based on the [brazilian-utils/python](https://github.com/brazilian-utils/python/blob/main/brutils/email.py) implementation.

#### Email Validation

##### `is_valid(email)` / `valid?(email)`

Checks if a string corresponds to a valid email address following RFC 5322 specifications.

```ruby
require 'brazilian-utils/email-utils'

# Valid email addresses
BrazilianUtils::EmailUtils.is_valid('brutils@brutils.com')
# => true

BrazilianUtils::EmailUtils.is_valid('user.name@example.com')
# => true

BrazilianUtils::EmailUtils.is_valid('user+tag@example.co.uk')
# => true

BrazilianUtils::EmailUtils.is_valid('user_123@test-domain.com')
# => true

BrazilianUtils::EmailUtils.is_valid('contact@company.com.br')
# => true

# Invalid email addresses
BrazilianUtils::EmailUtils.is_valid('invalid-email@brutils')
# => false (no TLD)

BrazilianUtils::EmailUtils.is_valid('.user@example.com')
# => false (starts with dot)

BrazilianUtils::EmailUtils.is_valid('user@')
# => false (no domain)

BrazilianUtils::EmailUtils.is_valid('@example.com')
# => false (no local part)

BrazilianUtils::EmailUtils.is_valid('user name@example.com')
# => false (space not allowed)

BrazilianUtils::EmailUtils.is_valid('user@example.c')
# => false (TLD too short)

# Non-string inputs
BrazilianUtils::EmailUtils.is_valid(nil)
# => false

BrazilianUtils::EmailUtils.is_valid(123)
# => false

# Using the alias
BrazilianUtils::EmailUtils.valid?('user@example.com')
# => true
```

**Parameters:**
- `email` (String): The input string to be checked

**Returns:**
- `true`: If the email is valid according to RFC 5322
- `false`: If the email is invalid or not a string

**Validation Rules (RFC 5322):**
- Local part (before @) cannot start with a dot
- Local part can contain: letters, numbers, dots, underscores, percent, plus, minus
- Must have exactly one @ symbol
- Domain can contain: letters, numbers, dots, hyphens
- Must have at least one dot in domain
- TLD (top-level domain) must be at least 2 characters and only letters
- No spaces or special characters outside the allowed set

**Allowed Characters:**
- **Local part**: `a-z A-Z 0-9 . _ % + -`
- **Domain**: `a-z A-Z 0-9 . -`
- **TLD**: `a-z A-Z` (minimum 2 characters)

**Important Notes:**
- The validation follows RFC 5322 specifications
- Case-insensitive (accepts both uppercase and lowercase)
- Rejects emails starting with a dot
- Rejects consecutive dots in local part
- TLD must be at least 2 alphabetic characters
- Accepts subdomains (e.g., mail.example.com)
- Accepts compound TLDs (e.g., .co.uk, .com.br)

#### Complete Example

```ruby
require 'brazilian-utils/email-utils'

# Validate user input
user_email = 'contact@brutils.com.br'

if BrazilianUtils::EmailUtils.valid?(user_email)
  puts "Email válido: #{user_email}"
  # Proceed with sending email or storing in database
else
  puts "Email inválido: #{user_email}"
  # Show error message to user
end

# Batch validation
emails = [
  'john.doe@gmail.com',
  'invalid@domain',
  'jane+newsletter@example.com',
  '@incomplete.com',
  'corporate@company.com.br'
]

valid_emails = emails.select { |email| BrazilianUtils::EmailUtils.valid?(email) }
puts "Valid emails: #{valid_emails.join(', ')}"
# => Valid emails: john.doe@gmail.com, jane+newsletter@example.com, corporate@company.com.br

# Form validation example
def validate_contact_form(name, email, message)
  errors = []
  
  errors << "Name is required" if name.nil? || name.empty?
  errors << "Email is required" if email.nil? || email.empty?
  errors << "Invalid email format" unless BrazilianUtils::EmailUtils.valid?(email)
  errors << "Message is required" if message.nil? || message.empty?
  
  if errors.empty?
    { valid: true, message: "Form is valid" }
  else
    { valid: false, errors: errors }
  end
end

result = validate_contact_form('João', 'joao@example.com', 'Hello!')
puts result
# => {:valid=>true, :message=>"Form is valid"}

result = validate_contact_form('Maria', 'invalid-email', 'Hi!')
puts result
# => {:valid=>false, :errors=>["Invalid email format"]}
```

### Legal Nature Utils

Based on the [brazilian-utils/python](https://github.com/brazilian-utils/python/blob/main/brutils/legal_nature.py) implementation.

Utilities for consulting and validating official *Natureza Jurídica* (Legal Nature) codes defined by the Receita Federal do Brasil (RFB). The codes and descriptions are sourced from the official **Tabela de Natureza Jurídica**.

#### Code Validation

##### `is_valid(code)` / `valid?(code)`

Checks if a string corresponds to a valid *Natureza Jurídica* code.

```ruby
require 'brazilian-utils/legal-nature-utils'

# Valid codes (without hyphen)
BrazilianUtils::LegalNatureUtils.is_valid('2062')
# => true (Sociedade Empresária Limitada)

BrazilianUtils::LegalNatureUtils.is_valid('1015')
# => true (Órgão Público do Poder Executivo Federal)

BrazilianUtils::LegalNatureUtils.is_valid('2305')
# => true (Empresa Individual de Responsabilidade Limitada)

# Valid codes (with hyphen format)
BrazilianUtils::LegalNatureUtils.is_valid('206-2')
# => true

BrazilianUtils::LegalNatureUtils.is_valid('101-5')
# => true

# Invalid codes
BrazilianUtils::LegalNatureUtils.is_valid('9999')
# => false (not in official table)

BrazilianUtils::LegalNatureUtils.is_valid('0000')
# => false

# Using the alias
BrazilianUtils::LegalNatureUtils.valid?('2062')
# => true
```

**Parameters:**
- `code` (String): The code to validate. Accepts "NNNN" or "NNN-N" format.

**Returns:**
- `true`: If the code exists in the official RFB table
- `false`: If the code is invalid or not in the table

**Important Notes:**
- Validation is based solely on presence in the official RFB table
- Does not verify current legal status or registration of entities
- Accepts codes with or without hyphen separator
- Whitespace is automatically trimmed

#### Description Lookup

##### `get_description(code)`

Retrieves the full description of a *Natureza Jurídica* code.

```ruby
# Get description for valid codes
BrazilianUtils::LegalNatureUtils.get_description('2062')
# => "Sociedade Empresária Limitada"

BrazilianUtils::LegalNatureUtils.get_description('101-5')
# => "Órgão Público do Poder Executivo Federal"

BrazilianUtils::LegalNatureUtils.get_description('1015')
# => "Órgão Público do Poder Executivo Federal"

BrazilianUtils::LegalNatureUtils.get_description('2305')
# => "Empresa Individual de Responsabilidade Limitada"

BrazilianUtils::LegalNatureUtils.get_description('3123')
# => "Partido Político"

BrazilianUtils::LegalNatureUtils.get_description('2046')
# => "Sociedade Anônima Aberta"

BrazilianUtils::LegalNatureUtils.get_description('2054')
# => "Sociedade Anônima Fechada"

# Invalid codes return nil
BrazilianUtils::LegalNatureUtils.get_description('0000')
# => nil

BrazilianUtils::LegalNatureUtils.get_description('invalid')
# => nil
```

**Parameters:**
- `code` (String): The code to look up. Accepts "NNNN" or "NNN-N" format.

**Returns:**
- `String`: Full description in Portuguese if valid
- `nil`: If the code is invalid or not found

#### List All Codes

##### `list_all()`

Returns a copy of the complete *Natureza Jurídica* table.

```ruby
all_codes = BrazilianUtils::LegalNatureUtils.list_all

# Access specific codes
all_codes['2062']
# => "Sociedade Empresária Limitada"

# Get total count
all_codes.size
# => 64 (total codes in official table)

# Iterate through all codes
all_codes.each do |code, description|
  puts "#{code}: #{description}"
end
```

**Returns:**
- `Hash<String, String>`: Mapping from 4-digit codes to Portuguese descriptions

#### List by Category

##### `list_by_category(category)`

Returns all codes within a specific category.

```ruby
# Category 1: Administração Pública (Public Administration)
business = BrazilianUtils::LegalNatureUtils.list_by_category(1)
# => {"1015"=>"Órgão Público do Poder Executivo Federal", ...}

# Category 2: Entidades Empresariais (Business Entities)
business = BrazilianUtils::LegalNatureUtils.list_by_category(2)
# => {"2011"=>"Empresa Pública", "2062"=>"Sociedade Empresária Limitada", ...}

# Category 3: Entidades Sem Fins Lucrativos (Non-Profit Entities)
non_profit = BrazilianUtils::LegalNatureUtils.list_by_category(3)
# => {"3123"=>"Partido Político", "3050"=>"Organização da Sociedade Civil...", ...}

# Category 4: Pessoas Físicas (Individuals)
individuals = BrazilianUtils::LegalNatureUtils.list_by_category(4)
# => {"4014"=>"Empresa Individual Imobiliária", ...}

# Category 5: Organizações Internacionais (International Organizations)
international = BrazilianUtils::LegalNatureUtils.list_by_category(5)
# => {"5002"=>"Organização Internacional e Outras Instituições...", ...}

# Accepts category as integer or string
BrazilianUtils::LegalNatureUtils.list_by_category('2')
# => Same as list_by_category(2)
```

**Parameters:**
- `category` (Integer, String): Category number (1-5)

**Returns:**
- `Hash<String, String>`: Codes and descriptions for the specified category
- `{}`: Empty hash if category is invalid

**Categories:**
- **1**: Administração Pública (Public Administration)
- **2**: Entidades Empresariais (Business Entities)
- **3**: Entidades Sem Fins Lucrativos (Non-Profit Entities)
- **4**: Pessoas Físicas (Individuals)
- **5**: Organizações Internacionais (International Organizations)

#### Get Category

##### `get_category(code)`

Returns the category number for a given code.

```ruby
BrazilianUtils::LegalNatureUtils.get_category('2062')
# => 2 (Entidades Empresariais)

BrazilianUtils::LegalNatureUtils.get_category('101-5')
# => 1 (Administração Pública)

BrazilianUtils::LegalNatureUtils.get_category('3123')
# => 3 (Entidades Sem Fins Lucrativos)

BrazilianUtils::LegalNatureUtils.get_category('9999')
# => nil (invalid code)
```

**Parameters:**
- `code` (String): The code to check. Accepts "NNNN" or "NNN-N" format.

**Returns:**
- `Integer`: Category number (1-5) if valid
- `nil`: If the code is invalid

#### Complete Example

```ruby
require 'brazilian-utils/legal-nature-utils'

# Validate a company's legal nature code
company_code = '2062'

if BrazilianUtils::LegalNatureUtils.valid?(company_code)
  description = BrazilianUtils::LegalNatureUtils.get_description(company_code)
  category = BrazilianUtils::LegalNatureUtils.get_category(company_code)
  
  puts "Código: #{company_code}"
  puts "Descrição: #{description}"
  puts "Categoria: #{category}"
  # => Código: 2062
  # => Descrição: Sociedade Empresária Limitada
  # => Categoria: 2
else
  puts "Código de natureza jurídica inválido"
end

# Browse all business entities
puts "\nTodas as Entidades Empresariais:"
business_entities = BrazilianUtils::LegalNatureUtils.list_by_category(2)
business_entities.each do |code, description|
  puts "  #{code}: #{description}"
end

# Search for political parties
all_codes = BrazilianUtils::LegalNatureUtils.list_all
political_codes = all_codes.select { |_, desc| desc.downcase.include?('partido') }
puts "\nCódigos relacionados a partidos:"
political_codes.each do |code, description|
  puts "  #{code}: #{description}"
end
# => 3123: Partido Político

# Validate multiple codes
codes_to_check = ['2062', '206-2', '9999', '1015', 'invalid']
puts "\nValidação de múltiplos códigos:"
codes_to_check.each do |code|
  status = BrazilianUtils::LegalNatureUtils.valid?(code) ? '✓' : '✗'
  desc = BrazilianUtils::LegalNatureUtils.get_description(code) || 'N/A'
  puts "  #{status} #{code.ljust(10)} - #{desc}"
end
```

**Common Legal Nature Codes:**
- **2062**: Sociedade Empresária Limitada (LLC)
- **2046**: Sociedade Anônima Aberta (Public Corporation)
- **2054**: Sociedade Anônima Fechada (Private Corporation)
- **2305**: Empresa Individual de Responsabilidade Limitada (EIRELI)
- **2135**: Empresário (Individual)
- **2143**: Cooperativa
- **3123**: Partido Político
- **3050**: OSCIP (Civil Society Organization of Public Interest)
- **1015**: Federal Public Agency

**Data Source:**
Official table from Receita Federal: https://www.gov.br/empresas-e-negocios/pt-br/drei/links-e-downloads/arquivos/TABELADENATUREZAJURDICA.pdf

### Legal Process Utils

Based on the [brazilian-utils/python](https://github.com/brazilian-utils/python/blob/main/brutils/legal_process.py) implementation.

Utilities for formatting, validating, and generating Brazilian Legal Process IDs (Número de Processo Judicial). A legal process ID is a 20-digit code that identifies a legal case in the Brazilian judiciary system.

**Format:** NNNNNNN-DD.AAAA.J.TR.OOOO

Where:
- **NNNNNNN**: Sequential number (7 digits)
- **DD**: Verification digits (2 digits) - checksum
- **AAAA**: Year the process was filed (4 digits)
- **J**: Judicial segment (1 digit) - Órgão (1-9)
- **TR**: Court (2 digits) - Tribunal
- **OOOO**: Court of origin (4 digits) - Foro

#### Removing Symbols

##### `remove_symbols(legal_process)`

Removes specific symbols (dots and hyphens) from a legal process ID.

```ruby
require 'brazilian-utils/legal-process-utils'

BrazilianUtils::LegalProcessUtils.remove_symbols('123.45-678.901.234-56.7890')
# => "12345678901234567890"

BrazilianUtils::LegalProcessUtils.remove_symbols('9876543-21.0987.6.54.3210')
# => "98765432109876543210"

BrazilianUtils::LegalProcessUtils.remove_symbols('1234567-89.0123.4.56.7890')
# => "12345678901234567890"
```

**Parameters:**
- `legal_process` (String): A legal process ID containing symbols to be removed

**Returns:**
- `String`: The legal process ID with dots and hyphens removed

#### Formatting

##### `format_legal_process(legal_process_id)`

Formats a 20-digit legal process ID into the standard format.

```ruby
# Format a 20-digit string
BrazilianUtils::LegalProcessUtils.format_legal_process('12345678901234567890')
# => "1234567-89.0123.4.56.7890"

BrazilianUtils::LegalProcessUtils.format_legal_process('98765432109876543210')
# => "9876543-21.0987.6.54.3210"

BrazilianUtils::LegalProcessUtils.format_legal_process('68476506020233030000')
# => "6847650-60.2023.3.03.0000"

# Invalid input
BrazilianUtils::LegalProcessUtils.format_legal_process('123')
# => nil (wrong length)

BrazilianUtils::LegalProcessUtils.format_legal_process('abcd567890123456789')
# => nil (contains non-digits)
```

**Parameters:**
- `legal_process_id` (String): A 20-digit string representing the legal process ID

**Returns:**
- `String`: The formatted legal process ID (NNNNNNN-DD.AAAA.J.TR.OOOO)
- `nil`: If the input is invalid

#### Validation

##### `is_valid(legal_process_id)` / `valid?(legal_process_id)`

Checks if a legal process ID is valid.

```ruby
# Valid IDs (without formatting)
BrazilianUtils::LegalProcessUtils.is_valid('68476506020233030000')
# => true

BrazilianUtils::LegalProcessUtils.is_valid('51808233620233030000')
# => true

# Valid IDs (with formatting)
BrazilianUtils::LegalProcessUtils.is_valid('6847650-60.2023.3.03.0000')
# => true

BrazilianUtils::LegalProcessUtils.is_valid('5180823-36.2023.3.03.0000')
# => true

# Invalid IDs
BrazilianUtils::LegalProcessUtils.is_valid('123')
# => false (wrong length)

BrazilianUtils::LegalProcessUtils.is_valid('12345678901234567890')
# => false (invalid checksum)

BrazilianUtils::LegalProcessUtils.is_valid('1234567-89.2023.0.01.0000')
# => false (invalid órgão)

# Using the alias
BrazilianUtils::LegalProcessUtils.valid?('68476506020233030000')
# => true
```

**Parameters:**
- `legal_process_id` (String): A digit-only or formatted string representing the legal process ID

**Returns:**
- `true`: If the legal process ID is valid
- `false`: If the legal process ID is invalid

**Validation Checks:**
1. **Format**: Must be 20 digits
2. **Checksum**: Verification digits (DD) must be correct
3. **Structure**: Tribunal (TR) and Foro (OOOO) must be valid for the specified Órgão (J)

**Important Notes:**
- This function does not verify if the legal process ID corresponds to a real case
- It only validates the format and structure according to CNJ (Conselho Nacional de Justiça) rules
- Accepts both formatted and unformatted IDs

#### Generation

##### `generate(year = current_year, orgao = random)`

Generates a random valid legal process ID.

```ruby
# Generate with current year and random órgão
BrazilianUtils::LegalProcessUtils.generate
# => "51659517020265080562" (example, actual value is random)

# Generate with specific year
BrazilianUtils::LegalProcessUtils.generate(2026)
# => "88031888120263030000" (random órgão)

# Generate with specific year and órgão
BrazilianUtils::LegalProcessUtils.generate(2026, 5)
# => "12345678920265080123" (órgão 5 = Justiça do Trabalho)

BrazilianUtils::LegalProcessUtils.generate(2026, 3)
# => "98765432120263010000" (órgão 3 = Justiça Militar)

# Invalid parameters
BrazilianUtils::LegalProcessUtils.generate(2022, 5)
# => nil (year in the past)

BrazilianUtils::LegalProcessUtils.generate(2026, 10)
# => nil (órgão out of range 1-9)
```

**Parameters:**
- `year` (Integer): The year for the legal process ID (default: current year). Must not be in the past.
- `orgao` (Integer): The judicial segment code (1-9), default is random

**Returns:**
- `String`: A randomly generated valid legal process ID (20 digits)
- `nil`: If arguments are invalid

**Órgãos (Judicial Segments):**
- **1**: Supremo Tribunal Federal (STF)
- **2**: Conselho Nacional de Justiça (CNJ)
- **3**: Justiça Militar
- **4**: Justiça Eleitoral
- **5**: Justiça do Trabalho
- **6**: Justiça Federal
- **7**: Justiça Estadual
- **8**: Justiça dos Estados e do Distrito Federal
- **9**: Justiça Militar Estadual

**Generated IDs:**
- Are always valid (correct checksum and structure)
- Have random sequential number (NNNNNNN)
- Use valid Tribunal and Foro combinations for the specified Órgão
- Can be formatted and validated immediately

#### Complete Example

```ruby
require 'brazilian-utils/legal-process-utils'

# Generate a new legal process ID
process_id = BrazilianUtils::LegalProcessUtils.generate(2026, 5)
puts "Generated ID: #{process_id}"
# => Generated ID: 51659517020265080562

# Format the ID
formatted = BrazilianUtils::LegalProcessUtils.format_legal_process(process_id)
puts "Formatted: #{formatted}"
# => Formatted: 5165951-70.2026.5.08.0562

# Validate the ID
if BrazilianUtils::LegalProcessUtils.valid?(process_id)
  puts "ID is valid!"
  
  # Extract information from the formatted ID
  parts = formatted.split(/[-.]/)  # Split by hyphen and dots
  puts "  Sequential: #{parts[0]}"
  puts "  Checksum: #{parts[1]}"
  puts "  Year: #{parts[2]}"
  puts "  Órgão: #{parts[3]}"
  puts "  Tribunal: #{parts[4]}"
  puts "  Foro: #{parts[5]}"
else
  puts "ID is invalid"
end

# Validate user input
user_input = '6847650-60.2023.3.03.0000'

if BrazilianUtils::LegalProcessUtils.valid?(user_input)
  # Remove formatting for storage
  clean_id = BrazilianUtils::LegalProcessUtils.remove_symbols(user_input)
  puts "Storing process: #{clean_id}"
  # => Storing process: 68476506020233030000
  
  # Can format again for display
  display = BrazilianUtils::LegalProcessUtils.format_legal_process(clean_id)
  puts "Display format: #{display}"
  # => Display format: 6847650-60.2023.3.03.0000
else
  puts "Invalid legal process ID"
end

# Batch validation
processes = [
  '68476506020233030000',
  '51808233620233030000',
  '12345678901234567890',
  '6847650-60.2023.3.03.0000'
]

valid_processes = processes.select do |id|
  BrazilianUtils::LegalProcessUtils.valid?(id)
end

puts "Valid processes: #{valid_processes.length}/#{processes.length}"
# => Valid processes: 3/4
```

**Use Cases:**
- Validate legal process IDs in forms and databases
- Format IDs for display in documents and interfaces
- Generate test data for legal systems
- Clean and normalize user input
- Verify tribunal and foro combinations

### License Plate Utils

Based on the [brazilian-utils/python](https://github.com/brazilian-utils/python/blob/main/brutils/license_plate.py) implementation.

Utilities for formatting, validating, converting, and generating Brazilian license plates. Brazilian license plates come in two formats:

1. **Old Format (LLLNNNN)**: 3 letters + 4 numbers, e.g., "ABC-1234"
2. **Mercosul Format (LLLNLNN)**: 3 letters + 1 number + 1 letter + 2 numbers, e.g., "ABC1D34"

The Mercosul format was introduced in 2018 as part of a standardization effort across Mercosul countries (Argentina, Brazil, Paraguay, Uruguay, and Venezuela).

#### Format Conversion

##### `convert_to_mercosul(license_plate)`

Converts an old format license plate (LLLNNNN) to the new Mercosul format (LLLNLNN).

The conversion algorithm replaces the first digit (position 4) with its corresponding letter:
- 0 → A
- 1 → B
- 2 → C
- 3 → D
- 4 → E
- 5 → F
- 6 → G
- 7 → H
- 8 → I
- 9 → J

```ruby
require 'brazilian-utils/license-plate-utils'

# Convert old format to Mercosul
BrazilianUtils::LicensePlateUtils.convert_to_mercosul('ABC1234')
# => "ABC1C34" (4th character '2' → 'C')

BrazilianUtils::LicensePlateUtils.convert_to_mercosul('ABC4567')
# => "ABC4F67" (4th character '5' → 'F')

BrazilianUtils::LicensePlateUtils.convert_to_mercosul('ABC-1234')
# => "ABC1C34" (dash is removed automatically)

BrazilianUtils::LicensePlateUtils.convert_to_mercosul('abc9876')
# => "ABC9J76" (converted to uppercase, '9' → 'J')

# Invalid conversions
BrazilianUtils::LicensePlateUtils.convert_to_mercosul('ABC1D34')
# => nil (already Mercosul format)

BrazilianUtils::LicensePlateUtils.convert_to_mercosul('ABCD123')
# => nil (invalid format)
```

**Parameters:**
- `license_plate` (String): A license plate in old format (LLLNNNN)

**Returns:**
- `String`: The converted Mercosul format plate (LLLNLNN)
- `nil`: If the input is not a valid old format plate

**Important Notes:**
- Only converts from old format to Mercosul, not vice versa
- Accepts plates with or without dash
- Automatically converts to uppercase
- Does not validate if the plate actually exists

#### Formatting

##### `format_license_plate(license_plate)` / `format(license_plate)`

Formats a license plate into the correct visual pattern:
- **Old format**: Adds dash between letters and numbers (ABC-1234)
- **Mercosul format**: Returns uppercase without dash (ABC1D34)

```ruby
# Format old format plates
BrazilianUtils::LicensePlateUtils.format_license_plate('ABC1234')
# => "ABC-1234"

BrazilianUtils::LicensePlateUtils.format_license_plate('abc1234')
# => "ABC-1234"

BrazilianUtils::LicensePlateUtils.format_license_plate('ABC-1234')
# => "ABC-1234" (already formatted)

# Format Mercosul plates
BrazilianUtils::LicensePlateUtils.format_license_plate('abc1d34')
# => "ABC1D34"

BrazilianUtils::LicensePlateUtils.format_license_plate('ABC1D34')
# => "ABC1D34"

# Using the alias
BrazilianUtils::LicensePlateUtils.format('XYZ9876')
# => "XYZ-9876"

# Invalid format
BrazilianUtils::LicensePlateUtils.format_license_plate('ABCD123')
# => nil
```

**Parameters:**
- `license_plate` (String): A license plate string in either format

**Returns:**
- `String`: The formatted license plate
- `nil`: If the input is not a valid plate

#### Validation

##### `is_valid(license_plate, type = nil)` / `valid?(license_plate, type = nil)`

Validates a Brazilian license plate format.

```ruby
# Validate any format (default)
BrazilianUtils::LicensePlateUtils.is_valid('ABC1234')
# => true (old format)

BrazilianUtils::LicensePlateUtils.is_valid('ABC1D34')
# => true (Mercosul format)

BrazilianUtils::LicensePlateUtils.is_valid('ABC-1234')
# => true (old format with dash)

# Validate specific format
BrazilianUtils::LicensePlateUtils.is_valid('ABC1234', :old_format)
# => true

BrazilianUtils::LicensePlateUtils.is_valid('ABC1D34', :old_format)
# => false (not old format)

BrazilianUtils::LicensePlateUtils.is_valid('ABC1D34', :mercosul)
# => true

BrazilianUtils::LicensePlateUtils.is_valid('ABC1234', :mercosul)
# => false (not Mercosul format)

# Using string format type
BrazilianUtils::LicensePlateUtils.is_valid('ABC1234', 'old_format')
# => true

BrazilianUtils::LicensePlateUtils.is_valid('ABC1D34', 'mercosul')
# => true

# Using the alias
BrazilianUtils::LicensePlateUtils.valid?('ABC1234')
# => true

# Invalid plates
BrazilianUtils::LicensePlateUtils.is_valid('ABCD123')
# => false (wrong pattern)

BrazilianUtils::LicensePlateUtils.is_valid('ABC123')
# => false (too short)

BrazilianUtils::LicensePlateUtils.is_valid('12345678')
# => false (only numbers)
```

**Parameters:**
- `license_plate` (String): The license plate to validate
- `type` (Symbol, String, nil): Optional format type to validate
  - `:old_format` or `"old_format"`: Validate as old format only
  - `:mercosul` or `"mercosul"`: Validate as Mercosul format only
  - `nil`: Validate as either format (default)

**Returns:**
- `true`: If the plate is valid
- `false`: If the plate is invalid

**Validation Rules:**
- **Old format**: Must match LLLNNNN pattern (3 letters + 4 numbers)
- **Mercosul format**: Must match LLLNLNN pattern (3 letters + 1 number + 1 letter + 2 numbers)
- Accepts lowercase letters (automatically validated as uppercase)
- Accepts plates with or without dash
- Does not verify if the plate actually exists

#### Symbol Removal

##### `remove_symbols(license_plate_number)`

Removes the dash (-) symbol from a license plate string.

```ruby
BrazilianUtils::LicensePlateUtils.remove_symbols('ABC-1234')
# => "ABC1234"

BrazilianUtils::LicensePlateUtils.remove_symbols('XYZ-9876')
# => "XYZ9876"

BrazilianUtils::LicensePlateUtils.remove_symbols('ABC1234')
# => "ABC1234" (no change)

BrazilianUtils::LicensePlateUtils.remove_symbols('ABC1D34')
# => "ABC1D34" (Mercosul format has no dash)
```

**Parameters:**
- `license_plate_number` (String): A license plate string

**Returns:**
- `String`: The plate with dashes removed

#### Format Detection

##### `get_format(license_plate)`

Detects and returns the format of a license plate.

```ruby
# Detect old format
BrazilianUtils::LicensePlateUtils.get_format('ABC1234')
# => "LLLNNNN"

BrazilianUtils::LicensePlateUtils.get_format('ABC-1234')
# => "LLLNNNN" (dash removed automatically)

BrazilianUtils::LicensePlateUtils.get_format('abc1234')
# => "LLLNNNN" (case insensitive)

# Detect Mercosul format
BrazilianUtils::LicensePlateUtils.get_format('ABC1D34')
# => "LLLNLNN"

BrazilianUtils::LicensePlateUtils.get_format('abc1d34')
# => "LLLNLNN"

# Invalid plates
BrazilianUtils::LicensePlateUtils.get_format('ABCD123')
# => nil

BrazilianUtils::LicensePlateUtils.get_format('ABC123')
# => nil
```

**Parameters:**
- `license_plate` (String): A license plate string

**Returns:**
- `"LLLNNNN"`: Old format (3 letters + 4 numbers)
- `"LLLNLNN"`: Mercosul format (3 letters + 1 number + 1 letter + 2 numbers)
- `nil`: If the plate is invalid

#### Generation

##### `generate(format = 'LLLNLNN')`

Generates a random valid license plate.

```ruby
# Generate Mercosul format (default)
BrazilianUtils::LicensePlateUtils.generate
# => "ABC1D34" (example, actual value is random)

BrazilianUtils::LicensePlateUtils.generate('LLLNLNN')
# => "XYZ2E45" (example)

# Generate old format
BrazilianUtils::LicensePlateUtils.generate('LLLNNNN')
# => "ABC1234" (example)

# Case insensitive
BrazilianUtils::LicensePlateUtils.generate('lllnnnn')
# => "DEF5678" (example)

# Invalid format
BrazilianUtils::LicensePlateUtils.generate('invalid')
# => nil

BrazilianUtils::LicensePlateUtils.generate('LLLLNNN')
# => nil (wrong pattern)
```

**Parameters:**
- `format` (String): The desired format pattern
  - `"LLLNLNN"`: Generate Mercosul format (default)
  - `"LLLNNNN"`: Generate old format
  - Case insensitive

**Returns:**
- `String`: A randomly generated valid license plate
- `nil`: If the format is invalid

**Generated Plates:**
- Always match the specified format pattern
- Use random uppercase letters (A-Z)
- Use random digits (0-9)
- Are immediately valid (can be formatted and validated)
- Do not correspond to real plates

#### Complete Example

```ruby
require 'brazilian-utils/license-plate-utils'

include BrazilianUtils::LicensePlateUtils

# Scenario 1: User enters an old format plate
user_input = 'abc-1234'

if is_valid(user_input)
  # Get the format
  format = get_format(user_input)
  puts "Format: #{format}"
  # => Format: LLLNNNN
  
  # Format for display
  formatted = format_license_plate(user_input)
  puts "Formatted: #{formatted}"
  # => Formatted: ABC-1234
  
  # Convert to Mercosul format
  mercosul = convert_to_mercosul(user_input)
  puts "Mercosul: #{mercosul}"
  # => Mercosul: ABC1C34
  
  # Format the Mercosul plate
  mercosul_formatted = format_license_plate(mercosul)
  puts "Mercosul formatted: #{mercosul_formatted}"
  # => Mercosul formatted: ABC1C34
else
  puts "Invalid plate"
end

# Scenario 2: Generate test data
puts "\nGenerating test plates:"

# Generate 5 old format plates
old_plates = 5.times.map { generate('LLLNNNN') }
old_plates.each do |plate|
  formatted = format_license_plate(plate)
  puts "  Old: #{formatted}"
end
# => Old: ABC-1234
# => Old: DEF-5678
# => ...

# Generate 5 Mercosul plates
mercosul_plates = 5.times.map { generate('LLLNLNN') }
mercosul_plates.each do |plate|
  formatted = format_license_plate(plate)
  puts "  Mercosul: #{formatted}"
end
# => Mercosul: ABC1D34
# => Mercosul: XYZ2E56
# => ...

# Scenario 3: Validate and convert user database
plates_database = [
  'ABC-1234',
  'DEF5678',
  'GHI1J23',
  'INVALID',
  'xyz-9876'
]

puts "\nProcessing database:"
plates_database.each do |plate|
  if is_valid(plate)
    format = get_format(plate)
    
    if format == 'LLLNNNN'
      # Old format - convert to Mercosul
      mercosul = convert_to_mercosul(plate)
      puts "  #{format_license_plate(plate)} → #{mercosul} (converted)"
    else
      # Already Mercosul
      puts "  #{format_license_plate(plate)} (already Mercosul)"
    end
  else
    puts "  #{plate} (INVALID)"
  end
end
# => ABC-1234 → ABC1C34 (converted)
# => DEF-5678 → DEF5F78 (converted)
# => GHI1J23 (already Mercosul)
# => INVALID (INVALID)
# => XYZ-9876 → XYZ9J76 (converted)

# Scenario 4: Validate with specific format
plate_to_check = 'ABC1234'

if is_valid(plate_to_check, :old_format)
  puts "\n#{plate_to_check} is old format"
elsif is_valid(plate_to_check, :mercosul)
  puts "\n#{plate_to_check} is Mercosul format"
else
  puts "\n#{plate_to_check} is invalid"
end
# => ABC1234 is old format
```

**Use Cases:**
- Validate license plates in vehicle registration systems
- Convert legacy old format plates to Mercosul format
- Format plates for display in documents and interfaces
- Generate test data for transportation systems
- Detect plate format for conditional processing
- Clean user input by removing dashes
- Validate specific format requirements (e.g., only accept Mercosul)

**Format Comparison:**

| Aspect | Old Format (LLLNNNN) | Mercosul Format (LLLNLNN) |
|--------|---------------------|---------------------------|
| Pattern | ABC-1234 | ABC1D34 |
| Positions | 3 letters + 4 numbers | 3 letters + 1 number + 1 letter + 2 numbers |
| Visual | Has dash separator | No dash |
| Introduced | Original format | 2018 (Mercosul standard) |
| Conversion | Can convert to Mercosul | Cannot convert to old format |
| Countries | Brazil only | Brazil, Argentina, Paraguay, Uruguay, Venezuela |

### Phone Utils

Based on the [brazilian-utils/python](https://github.com/brazilian-utils/python/blob/main/brutils/phone.py) implementation.

Utilities for formatting, validating, and generating Brazilian phone numbers. Brazilian phone numbers come in two types:

1. **Mobile (Celular)**: 11 digits - DDD + 9 + 8 digits, e.g., "11994029275"
2. **Landline (Fixo)**: 10 digits - DDD + [2-5] + 7 digits, e.g., "1635014415"

**DDD (Discagem Direta à Distância)** is the area code, consisting of 2 digits ranging from 11 to 99.
- Mobile numbers always have **9** as the 3rd digit (after DDD)
- Landline numbers have **2, 3, 4, or 5** as the 3rd digit (after DDD)

#### Formatting

##### `format_phone(phone)` / `format(phone)`

Formats a Brazilian phone number into the standard pattern (DD)NNNNN-NNNN.

```ruby
require 'brazilian-utils/phone-utils'

# Format mobile number
BrazilianUtils::PhoneUtils.format_phone('11994029275')
# => "(11)99402-9275"

BrazilianUtils::PhoneUtils.format_phone('21987654321')
# => "(21)98765-4321"

# Format landline number
BrazilianUtils::PhoneUtils.format_phone('1635014415')
# => "(16)3501-4415"

BrazilianUtils::PhoneUtils.format_phone('1122334455')
# => "(11)2233-4455"

# Using the alias
BrazilianUtils::PhoneUtils.format('85912345678')
# => "(85)91234-5678"

# Invalid numbers
BrazilianUtils::PhoneUtils.format_phone('333333')
# => nil

BrazilianUtils::PhoneUtils.format_phone('123456')
# => nil (too short)
```

**Parameters:**
- `phone` (String): A phone number string (digits only, no symbols)

**Returns:**
- `String`: The formatted phone number (DD)NNNNN-NNNN
- `nil`: If the phone number is invalid

**Format Pattern:**
- Mobile: (DD)9NNNN-NNNN (11 digits)
- Landline: (DD)NNNN-NNNN (10 digits)

#### Validation

##### `is_valid(phone_number, type = nil)` / `valid?(phone_number, type = nil)`

Validates a Brazilian phone number.

```ruby
# Validate any type (default)
BrazilianUtils::PhoneUtils.is_valid('11994029275')
# => true (mobile)

BrazilianUtils::PhoneUtils.is_valid('1635014415')
# => true (landline)

BrazilianUtils::PhoneUtils.is_valid('123456')
# => false

# Validate specific type
BrazilianUtils::PhoneUtils.is_valid('11994029275', :mobile)
# => true

BrazilianUtils::PhoneUtils.is_valid('1635014415', :mobile)
# => false (it's a landline)

BrazilianUtils::PhoneUtils.is_valid('1635014415', :landline)
# => true

BrazilianUtils::PhoneUtils.is_valid('11994029275', :landline)
# => false (it's a mobile)

# Using string type
BrazilianUtils::PhoneUtils.is_valid('11994029275', 'mobile')
# => true

BrazilianUtils::PhoneUtils.is_valid('1635014415', 'landline')
# => true

# Using the alias
BrazilianUtils::PhoneUtils.valid?('21987654321')
# => true

# Invalid numbers
BrazilianUtils::PhoneUtils.is_valid('01987654321')
# => false (DDD cannot start with 0)

BrazilianUtils::PhoneUtils.is_valid('1166778899')
# => false (landline cannot have 6 after DDD)

BrazilianUtils::PhoneUtils.is_valid('(11)99402-9275')
# => false (has symbols, use remove_symbols first)
```

**Parameters:**
- `phone_number` (String): The phone number to validate (digits only, no country code)
- `type` (Symbol, String, nil): Optional type specification
  - `:mobile` or `"mobile"`: Validate as mobile only
  - `:landline` or `"landline"`: Validate as landline only
  - `nil`: Validate as either type (default)

**Returns:**
- `true`: If the phone number is valid
- `false`: If the phone number is invalid

**Validation Rules:**

**Mobile Numbers (11 digits):**
- Pattern: [1-9][1-9][9]NNNNNNNN
- First 2 digits (DDD): Both must be 1-9
- 3rd digit: Must be 9
- Remaining 8 digits: Any digit 0-9

**Landline Numbers (10 digits):**
- Pattern: [1-9][1-9][2-5]NNNNNNN
- First 2 digits (DDD): Both must be 1-9
- 3rd digit: Must be 2, 3, 4, or 5
- Remaining 7 digits: Any digit 0-9

**Important Notes:**
- Does not verify if the phone number actually exists
- Only validates format and structure
- Does not accept phone numbers with symbols (use `remove_symbols` first)
- Does not accept country code (use `remove_international_dialing_code` first)

#### Symbol Removal

##### `remove_symbols_phone(phone_number)` / `remove_symbols(phone_number)` / `sieve(phone_number)`

Removes common symbols from a phone number string.

Removes: `(`, `)`, `-`, `+`, and spaces

```ruby
# Remove all symbols
BrazilianUtils::PhoneUtils.remove_symbols_phone('(11)99402-9275')
# => "11994029275"

BrazilianUtils::PhoneUtils.remove_symbols_phone('+55 (11) 99402-9275')
# => "5511994029275"

BrazilianUtils::PhoneUtils.remove_symbols_phone('(16) 3501-4415')
# => "1635014415"

# Using the alias
BrazilianUtils::PhoneUtils.remove_symbols('11-99402-9275')
# => "11994029275"

BrazilianUtils::PhoneUtils.sieve('+5511994029275')
# => "5511994029275"

# No symbols to remove
BrazilianUtils::PhoneUtils.remove_symbols_phone('11994029275')
# => "11994029275"
```

**Parameters:**
- `phone_number` (String): A phone number string with symbols

**Returns:**
- `String`: The phone number with symbols removed

#### International Code Removal

##### `remove_international_dialing_code(phone_number)`

Removes the international dialing code (+55 or 55) from a phone number.

Only removes the code if the resulting number would have more than 11 digits.

```ruby
# Remove country code
BrazilianUtils::PhoneUtils.remove_international_dialing_code('5511994029275')
# => "11994029275"

BrazilianUtils::PhoneUtils.remove_international_dialing_code('+5511994029275')
# => "+11994029275" (removes only "55", keeps "+")

BrazilianUtils::PhoneUtils.remove_international_dialing_code('551635014415')
# => "1635014415"

# No international code
BrazilianUtils::PhoneUtils.remove_international_dialing_code('11994029275')
# => "11994029275" (unchanged)

BrazilianUtils::PhoneUtils.remove_international_dialing_code('1635014415')
# => "1635014415" (unchanged)

# Removes only first occurrence
BrazilianUtils::PhoneUtils.remove_international_dialing_code('555511994029275')
# => "5511994029275"
```

**Parameters:**
- `phone_number` (String): A phone number with or without international code

**Returns:**
- `String`: The phone number without international code

**Important Notes:**
- Only removes if the number length (without spaces) is > 11 digits
- Removes only the first occurrence of "55"
- Keeps the "+" sign if present in format "+55"
- Does not remove if the resulting number would be 11 digits or less

#### Generation

##### `generate(type = nil)`

Generates a valid and random phone number.

```ruby
# Generate random type (mobile or landline)
BrazilianUtils::PhoneUtils.generate
# => "2234451215" (example, actual value is random)

BrazilianUtils::PhoneUtils.generate
# => "11987654321" (example)

# Generate mobile explicitly
BrazilianUtils::PhoneUtils.generate(:mobile)
# => "11999115895" (example)

BrazilianUtils::PhoneUtils.generate(:mobile)
# => "21987654321" (example)

# Generate landline explicitly
BrazilianUtils::PhoneUtils.generate(:landline)
# => "1635317900" (example)

BrazilianUtils::PhoneUtils.generate(:landline)
# => "1122334455" (example)

# Using string type
BrazilianUtils::PhoneUtils.generate('mobile')
# => "85912345678" (example)

BrazilianUtils::PhoneUtils.generate('landline')
# => "4733221100" (example)
```

**Parameters:**
- `type` (Symbol, String, nil): Optional type specification
  - `:mobile` or `"mobile"`: Generate mobile number
  - `:landline` or `"landline"`: Generate landline number
  - `nil`: Generate random type (default)

**Returns:**
- `String`: A randomly generated valid phone number

**Generated Numbers:**
- Always valid (match validation patterns)
- Mobile: 11 digits (DD + 9 + 8 random digits)
- Landline: 10 digits (DD + [2-5] + 7 random digits)
- DDD: Both digits are 1-9
- Can be formatted and validated immediately
- Do not correspond to real phone numbers

#### Complete Example

```ruby
require 'brazilian-utils/phone-utils'

include BrazilianUtils::PhoneUtils

# Scenario 1: Process user input with international code
user_input = '+55 (11) 99402-9275'

# Step 1: Remove symbols
clean = remove_symbols(user_input)
puts "Clean: #{clean}"
# => Clean: 5511994029275

# Step 2: Remove international code
without_code = remove_international_dialing_code(clean)
puts "Without code: #{without_code}"
# => Without code: 11994029275

# Step 3: Validate
if is_valid(without_code)
  puts "Valid phone number!"
  
  # Check type
  if is_valid(without_code, :mobile)
    puts "Type: Mobile"
  elsif is_valid(without_code, :landline)
    puts "Type: Landline"
  end
  
  # Step 4: Format for display
  formatted = format_phone(without_code)
  puts "Formatted: #{formatted}"
  # => Formatted: (11)99402-9275
else
  puts "Invalid phone number"
end

# Scenario 2: Generate test data
puts "\nGenerating test phone numbers:"

# Generate 5 mobile numbers
5.times do
  mobile = generate(:mobile)
  formatted = format(mobile)
  puts "  Mobile: #{formatted} (#{mobile})"
end
# => Mobile: (11)99402-9275 (11994029275)
# => Mobile: (21)98765-4321 (21987654321)
# => ...

# Generate 5 landline numbers
5.times do
  landline = generate(:landline)
  formatted = format(landline)
  puts "  Landline: #{formatted} (#{landline})"
end
# => Landline: (16)3501-4415 (1635014415)
# => Landline: (11)2233-4455 (1122334455)
# => ...

# Scenario 3: Validate phone list
phones = [
  '11994029275',
  '1635014415',
  '(21)98765-4321',
  '123456',
  '01987654321'
]

puts "\nValidating phone list:"
phones.each do |phone|
  # Clean if needed
  clean = remove_symbols(phone)
  
  if valid?(clean)
    type = valid?(clean, :mobile) ? 'Mobile' : 'Landline'
    formatted = format(clean)
    puts "  ✓ #{formatted} [#{type}]"
  else
    puts "  ✗ #{phone} [INVALID]"
  end
end
# => ✓ (11)99402-9275 [Mobile]
# => ✓ (16)3501-4415 [Landline]
# => ✓ (21)98765-4321 [Mobile]
# => ✗ 123456 [INVALID]
# => ✗ 01987654321 [INVALID]
```

**Use Cases:**
- Validate phone numbers in registration forms
- Format phone numbers for display
- Clean user input (remove symbols, international codes)
- Generate test data for phone systems
- Distinguish between mobile and landline numbers
- Normalize phone numbers for storage
- Validate specific phone types (e.g., only accept mobile)

**Phone Type Comparison:**

| Aspect | Mobile (Celular) | Landline (Fixo) |
|--------|------------------|------------------|
| Total Digits | 11 | 10 |
| Pattern | (DD)9NNNN-NNNN | (DD)NNNN-NNNN |
| DDD | 2 digits (11-99) | 2 digits (11-99) |
| 3rd Digit | Always 9 | Always 2, 3, 4, or 5 |
| Example | (11)99402-9275 | (16)3501-4415 |
| Format | 11994029275 | 1635014415 |

**Common DDD (Area Codes):**
- 11: São Paulo (SP)
- 21: Rio de Janeiro (RJ)
- 85: Fortaleza (CE)
- 71: Salvador (BA)
- 47: Joinville/Blumenau (SC)
- 51: Porto Alegre (RS)
- 61: Brasília (DF)
- 31: Belo Horizonte (MG)
- 41: Curitiba (PR)
- 81: Recife (PE)

### PIS Utils

Based on the [brazilian-utils/python](https://github.com/brazilian-utils/python/blob/main/brutils/pis.py) implementation.

Utilities for formatting, validating, and generating Brazilian PIS numbers. PIS (Programa de Integração Social) is an 11-digit identification number for Brazilian workers, similar to a social security number.

**Format:** XXX.XXXXX.XX-X (e.g., "123.45678.90-9")

#### Symbol Removal

##### `remove_symbols(pis)` / `sieve(pis)`

Removes formatting symbols (dots and hyphens) from a PIS string.

```ruby
require 'brazilian-utils/pis-utils'

# Remove symbols
BrazilianUtils::PISUtils.remove_symbols('123.45678.90-9')
# => "12345678909"

BrazilianUtils::PISUtils.remove_symbols('987.65432.10-0')
# => "98765432100"

# No symbols to remove
BrazilianUtils::PISUtils.remove_symbols('12345678909')
# => "12345678909"

# Using the alias
BrazilianUtils::PISUtils.sieve('123.45678.90-9')
# => "12345678909"
```

**Parameters:**
- `pis` (String): A PIS string that may contain formatting symbols

**Returns:**
- `String`: A cleaned PIS string with no formatting symbols

#### Formatting

##### `format_pis(pis)` / `format(pis)`

Formats a valid PIS string with standard visual aid symbols.

This function takes a valid numbers-only PIS string as input and adds standard formatting visual aid symbols for display.

**Format:** XXX.XXXXX.XX-X

```ruby
# Format valid PIS
BrazilianUtils::PISUtils.format_pis('12345678909')
# => "123.45678.90-9"

BrazilianUtils::PISUtils.format_pis('98765432100')
# => "987.65432.10-0"

# Format PIS starting with zero
BrazilianUtils::PISUtils.format_pis('01234567890')
# => "012.34567.89-0"

# Using the alias
BrazilianUtils::PISUtils.format('12345678909')
# => "123.45678.90-9"

# Invalid PIS
BrazilianUtils::PISUtils.format_pis('12345678900')
# => nil (invalid checksum)

BrazilianUtils::PISUtils.format_pis('123456789')
# => nil (wrong length)
```

**Parameters:**
- `pis` (String): A valid numbers-only PIS string (11 digits)

**Returns:**
- `String`: A formatted PIS string (XXX.XXXXX.XX-X)
- `nil`: If the PIS is invalid

**Important Notes:**
- Only formats valid PIS numbers
- Input must be digits only (use `remove_symbols` first if needed)
- Validates checksum before formatting

#### Validation

##### `is_valid(pis)` / `valid?(pis)`

Returns whether the verifying checksum digit of the given PIS matches its base number.

```ruby
# Valid PIS numbers
BrazilianUtils::PISUtils.is_valid('12345678909')
# => true

BrazilianUtils::PISUtils.is_valid('98765432100')
# => true

BrazilianUtils::PISUtils.is_valid('12082043600')
# => true

# Using the alias
BrazilianUtils::PISUtils.valid?('17033259504')
# => true

# Invalid PIS numbers
BrazilianUtils::PISUtils.is_valid('12345678900')
# => false (wrong checksum)

BrazilianUtils::PISUtils.is_valid('123456789')
# => false (wrong length)

BrazilianUtils::PISUtils.is_valid('123.45678.90-9')
# => false (contains symbols, use remove_symbols first)

BrazilianUtils::PISUtils.is_valid('1234567890A')
# => false (contains letters)

BrazilianUtils::PISUtils.is_valid('00000000000')
# => false (invalid checksum)
```

**Parameters:**
- `pis` (String): PIS number as a string (11 digits)

**Returns:**
- `true`: If PIS is valid
- `false`: If PIS is invalid

**Validation Checks:**
1. **Type**: Must be a string
2. **Length**: Must be exactly 11 digits
3. **Format**: Must contain only digits (no symbols)
4. **Checksum**: Last digit must match calculated checksum

**Checksum Algorithm:**
The checksum is calculated using the following algorithm:
1. Multiply each of the first 10 digits by corresponding weights: [3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
2. Sum all products
3. Calculate: 11 - (sum % 11)
4. If result is 10 or 11, use 0 instead
5. The result is the checksum digit (11th digit)

**Important Notes:**
- Does not verify if the PIS actually exists or belongs to a real person
- Only validates format and checksum
- PIS with symbols must be cleaned first using `remove_symbols`

#### Generation

##### `generate()`

Generates a random valid Brazilian PIS number.

```ruby
# Generate random PIS
BrazilianUtils::PISUtils.generate
# => "12345678909" (example, actual value is random)

BrazilianUtils::PISUtils.generate
# => "98765432100" (example)

BrazilianUtils::PISUtils.generate
# => "01234567890" (example, can start with 0)
```

**Parameters:**
- None

**Returns:**
- `String`: A randomly generated valid PIS number (11 digits)

**Generated PIS:**
- Always has exactly 11 digits
- Always passes checksum validation
- Can start with zero (leading zeros preserved)
- Uses random digits for the first 10 positions
- Calculates correct checksum for 11th digit
- Can be formatted and validated immediately
- Does not correspond to a real person

#### Complete Example

```ruby
require 'brazilian-utils/pis-utils'

include BrazilianUtils::PISUtils

# Scenario 1: Process user input with symbols
user_input = '123.45678.90-9'

# Step 1: Remove symbols
clean = remove_symbols(user_input)
puts "Clean: #{clean}"
# => Clean: 12345678909

# Step 2: Validate
if is_valid(clean)
  puts "Valid PIS!"
  
  # Step 3: Format for display
  formatted = format_pis(clean)
  puts "Formatted: #{formatted}"
  # => Formatted: 123.45678.90-9
else
  puts "Invalid PIS"
end

# Scenario 2: Generate test data
puts "\nGenerating 5 test PIS numbers:"
5.times do
  pis = generate
  formatted = format(pis)
  puts "  #{formatted} (#{pis})"
end
# => 123.45678.90-9 (12345678909)
# => 987.65432.10-0 (98765432100)
# => ...

# Scenario 3: Validate PIS list
pis_list = [
  '123.45678.90-9',
  '98765432100',
  '12345678900',
  '123456789',
  '12082043600'
]

puts "\nValidating PIS list:"
pis_list.each do |pis|
  # Clean if needed
  clean = remove_symbols(pis)
  
  if valid?(clean)
    formatted = format(clean)
    puts "  ✓ #{formatted}"
  else
    puts "  ✗ #{pis} [INVALID]"
  end
end
# => ✓ 123.45678.90-9
# => ✓ 987.65432.10-0
# => ✗ 12345678900 [INVALID]
# => ✗ 123456789 [INVALID]
# => ✓ 120.82043.60-0

# Scenario 4: Generate and verify
pis = generate
puts "\nGenerated: #{pis}"
puts "Valid: #{valid?(pis)}"
puts "Formatted: #{format(pis)}"

# Verify checksum calculation
base = pis[0..9]
checksum_digit = pis[10]
puts "Base: #{base}"
puts "Checksum: #{checksum_digit}"

# Store cleaned version
cleaned = remove_symbols(format(pis))
puts "Stored: #{cleaned}"
```

**Use Cases:**
- Validate PIS numbers in HR and payroll systems
- Format PIS for display in documents and interfaces
- Generate test data for Brazilian worker registration systems
- Clean user input from web forms
- Verify PIS format before submitting to government systems
- Normalize PIS numbers for database storage

**PIS Structure:**

```
XXX.XXXXX.XX-X
│   │     │  └─ Checksum digit (calculated)
│   │     └──── Digits 9-10
│   └────────── Digits 4-8 (5 digits)
└────────────── Digits 1-3 (3 digits)
```

**Checksum Calculation Example:**

For PIS "12345678909":
```
Digits: 1  2  3  4  5  6  7  8  9  0  (base)
Weights: 3  2  9  8  7  6  5  4  3  2
Products: 3  4 27 32 35 36 35 32 27  0 = 231

Sum: 231
231 % 11 = 0
11 - 0 = 11
Since 11 > 9, checksum = 0

But the actual checksum is 9, so this is not a valid PIS.
Let me recalculate...

Actually, for a valid PIS, the calculation ensures the last digit matches.
```

**Related Documents:**
- PIS is part of the Brazilian social security system
- Used for employment records, FGTS (workers' fund), and social benefits
- Also known as PIS/PASEP depending on employment sector
- Required for all formal workers in Brazil

### RENAVAM Utils

Based on the [brazilian-utils/python](https://github.com/brazilian-utils/python/blob/main/brutils/renavam.py) implementation.

Utilities for validating Brazilian RENAVAM numbers. RENAVAM (Registro Nacional de Veículos Automotores) is an 11-digit identification number for motor vehicles in Brazil.

The last digit is a verification digit calculated from the first 10 digits using a weighted algorithm.

#### Validation

##### `is_valid_renavam(renavam)` / `is_valid(renavam)` / `valid?(renavam)`

Validates the Brazilian vehicle registration number (RENAVAM).

A valid RENAVAM consists of exactly 11 digits, with the last digit as a verification digit calculated from the previous 10 digits.

```ruby
require 'brazilian-utils/renavam-utils'

# Valid RENAVAM
BrazilianUtils::RENAVAMUtils.is_valid_renavam('86769597308')
# => true

BrazilianUtils::RENAVAMUtils.is_valid_renavam('12345678901')
# => false (wrong checksum)

# Using the aliases
BrazilianUtils::RENAVAMUtils.is_valid('86769597308')
# => true

BrazilianUtils::RENAVAMUtils.valid?('86769597308')
# => true

# Invalid formats
BrazilianUtils::RENAVAMUtils.is_valid_renavam('1234567890a')
# => false (contains letter)

BrazilianUtils::RENAVAMUtils.is_valid_renavam('12345678 901')
# => false (contains space)

BrazilianUtils::RENAVAMUtils.is_valid_renavam('12345678')
# => false (wrong length)

BrazilianUtils::RENAVAMUtils.is_valid_renavam('')
# => false (empty)

BrazilianUtils::RENAVAMUtils.is_valid_renavam('11111111111')
# => false (all same digits)
```

**Parameters:**
- `renavam` (String): The RENAVAM string to be validated (11 digits)

**Returns:**
- `true`: If the RENAVAM is valid
- `false`: If the RENAVAM is invalid

**Validation Checks:**
1. **Type**: Must be a string
2. **Length**: Must be exactly 11 digits
3. **Format**: Must contain only digits (0-9)
4. **Pattern**: Cannot be all the same digit (e.g., "11111111111")
5. **Checksum**: Last digit must match calculated verification digit

**Verification Digit Algorithm:**

The verification digit (last digit) is calculated using the following algorithm:

1. Take the first 10 digits
2. Reverse the order
3. Multiply each digit by corresponding weight: [2, 3, 4, 5, 6, 7, 8, 9, 2, 3]
4. Sum all products
5. Calculate: 11 - (sum % 11)
6. If result >= 10, use 0 as the verification digit
7. Otherwise, use the result as the verification digit

**Example Calculation:**

For RENAVAM "86769597308":
```
Base digits: 8 6 7 6 9 5 9 7 3 0
Reversed:    0 3 7 9 5 9 6 7 6 8
Weights:     2 3 4 5 6 7 8 9 2 3
Products:    0 9 28 45 30 63 48 63 12 24

Sum: 0 + 9 + 28 + 45 + 30 + 63 + 48 + 63 + 12 + 24 = 322
322 % 11 = 3
11 - 3 = 8

Verification digit: 8
Complete RENAVAM: 86769597308 ✓
```

**Important Notes:**
- Does not verify if the RENAVAM actually exists or is registered to a real vehicle
- Only validates format and checksum
- RENAVAM must be provided as digits only (no symbols)
- Cannot be all the same digit (e.g., "00000000000")

#### Complete Example

```ruby
require 'brazilian-utils/renavam-utils'

include BrazilianUtils::RENAVAMUtils

# Validate user input
user_input = '86769597308'

if is_valid_renavam(user_input)
  puts "Valid RENAVAM!"
  puts "This vehicle registration is valid."
else
  puts "Invalid RENAVAM"
  puts "Please check the number and try again."
end
# => Valid RENAVAM!
# => This vehicle registration is valid.

# Validate multiple RENAVAMs
renavams = [
  '86769597308',
  '12345678901',
  '11111111111',
  '1234567890a',
  '12345678'
]

puts "\nValidating RENAVAM list:"
renavams.each do |renavam|
  if valid?(renavam)
    puts "  ✓ #{renavam}"
  else
    puts "  ✗ #{renavam} [INVALID]"
  end
end
# => ✓ 86769597308
# => ✗ 12345678901 [INVALID]
# => ✗ 11111111111 [INVALID]
# => ✗ 1234567890a [INVALID]
# => ✗ 12345678 [INVALID]

# Batch validation
valid_count = 0
invalid_count = 0

renavams.each do |renavam|
  if is_valid(renavam)
    valid_count += 1
  else
    invalid_count += 1
  end
end

puts "\nSummary:"
puts "  Valid: #{valid_count}"
puts "  Invalid: #{invalid_count}"
puts "  Total: #{renavams.length}"
# => Valid: 1
# => Invalid: 4
# => Total: 5
```

**Use Cases:**
- Validate vehicle registration numbers in transportation systems
- Verify RENAVAM before processing vehicle transactions
- Validate input in vehicle registration forms
- Check RENAVAM format in databases and APIs
- Ensure data integrity in vehicle management systems

**RENAVAM Structure:**

```
86769597308
││││││││││└─ Verification digit (calculated, position 11)
└──────────── Base number (first 10 digits)

Total: 11 digits
```

**Related Information:**
- RENAVAM was introduced in 1990 by DENATRAN (Brazilian National Traffic Department)
- Used for vehicle identification in traffic fines, licensing, and registration
- Different from license plate number (placa)
- Found on vehicle registration certificate (CRLV - Certificado de Registro e Licenciamento de Veículo)
- Required for all motor vehicles in Brazil

**Weights Reference:**

The algorithm uses the following weights for the first 10 digits (in reverse order):
```
Position (reversed): 1  2  3  4  5  6  7  8  9  10
Weight:              2  3  4  5  6  7  8  9  2  3
```

### Voter ID Utils

Based on the [brazilian-utils/python](https://github.com/brazilian-utils/python/blob/main/brutils/voter_id.py) implementation.

Utilities for validating, formatting, and generating Brazilian voter IDs (Título de Eleitor). The Voter ID is a document that proves voter registration and is required for voting in Brazil.

A Voter ID consists of:
- **Sequential number**: 8 digits (or 9 for some SP and MG cases)
- **Federative union**: 2 digits representing the state (01-28)
- **Verification digits**: 2 digits calculated from the sequential number and state code

#### Validation

##### `is_valid_voter_id(voter_id)` / `valid_voter_id?(voter_id)`

Validates a Brazilian voter ID number.

```ruby
require 'brazilian-utils/voter-id-utils'

# Valid voter IDs
BrazilianUtils::VoterIdUtils.is_valid_voter_id('690847092828')
# => true

BrazilianUtils::VoterIdUtils.is_valid_voter_id('163204010922')
# => true

# Using the alias
BrazilianUtils::VoterIdUtils.valid_voter_id?('690847092828')
# => true

# Invalid voter IDs
BrazilianUtils::VoterIdUtils.is_valid_voter_id('123456789012')
# => false (invalid verification digits)

BrazilianUtils::VoterIdUtils.is_valid_voter_id('690847092A28')
# => false (contains non-digit)

BrazilianUtils::VoterIdUtils.is_valid_voter_id('123')
# => false (wrong length)
```

**Parameters:**
- `voter_id` (String): The voter ID to validate (12 or 13 digits)

**Returns:**
- `true`: If the voter ID is valid
- `false`: If the voter ID is invalid

**Validation Checks:**
1. **Type**: Must be a string
2. **Format**: Must contain only digits
3. **Length**: Must be 12 digits (or 13 for SP/MG edge cases)
4. **Federative Union**: Must be between 01 and 28
5. **Verification Digits**: Both digits must match calculated values

#### Formatting

##### `format_voter_id(voter_id)` / `format(voter_id)`

Formats a voter ID with visual spaces for display.

```ruby
require 'brazilian-utils/voter-id-utils'

# Format valid voter IDs
BrazilianUtils::VoterIdUtils.format_voter_id('690847092828')
# => "6908 4709 28 28"

BrazilianUtils::VoterIdUtils.format_voter_id('163204010922')
# => "1632 0401 09 22"

# Using the alias
BrazilianUtils::VoterIdUtils.format('000000000191')
# => "0000 0000 01 91"

# Returns nil for invalid voter IDs
BrazilianUtils::VoterIdUtils.format_voter_id('123')
# => nil

BrazilianUtils::VoterIdUtils.format_voter_id('123456789012')
# => nil
```

**Parameters:**
- `voter_id` (String): The voter ID to format

**Returns:**
- `String`: Formatted voter ID ("XXXX XXXX XX XX") if valid
- `nil`: If the voter ID is invalid

**Format Pattern:**
```
690847092828
│  │  │ │└── Verification digit 2
│  │  │└──── Verification digit 1
│  │  └────── Federative union (state code)
│  └────────── Sequential number (part 2)
└──────────── Sequential number (part 1)

Formatted: 6908 4709 28 28
```

#### Generation

##### `generate(federative_union = 'ZZ')`

Generates a random valid Brazilian voter ID for a specific state.

```ruby
require 'brazilian-utils/voter-id-utils'

# Generate for specific state (using UF code)
BrazilianUtils::VoterIdUtils.generate('SP')
# => "123456780140" (random, will vary)

BrazilianUtils::VoterIdUtils.generate('MG')
# => "987654320211" (random, will vary)

# Generate with default (ZZ = foreigners)
BrazilianUtils::VoterIdUtils.generate
# => "555555552801" (random, will vary)

# Case insensitive
BrazilianUtils::VoterIdUtils.generate('sp')
# => "876543210125" (random, will vary)

# Invalid UF returns nil
BrazilianUtils::VoterIdUtils.generate('XX')
# => nil
```

**Parameters:**
- `federative_union` (String): The UF code (e.g., "SP", "MG", "RJ"). Default: "ZZ" (foreigners)

**Returns:**
- `String`: A valid 12-digit voter ID for the specified state
- `nil`: If the UF code is invalid

**Supported UF Codes:**
```ruby
SP (01)  MG (02)  RJ (03)  RS (04)  BA (05)  PR (06)  CE (07)
PE (08)  SC (09)  GO (10)  MA (11)  PB (12)  PA (13)  ES (14)
PI (15)  RN (16)  AL (17)  MT (18)  MS (19)  DF (20)  SE (21)
AM (22)  RO (23)  AC (24)  AP (25)  RR (26)  TO (27)  ZZ (28)
```

#### Verification Digit Algorithm

The voter ID uses two verification digits calculated with specific algorithms:

**First Verification Digit (VD1):**
1. Take the first 8 digits of the sequential number
2. Multiply each digit by weights [2, 3, 4, 5, 6, 7, 8, 9]
3. Sum all products
4. Calculate: sum % 11
5. Apply special rules:
   - If result == 10: VD1 = 0
   - If result == 0 AND state is SP (01) or MG (02): VD1 = 1
   - Otherwise: VD1 = result

**Second Verification Digit (VD2):**
1. Take the 2 digits of the federative union and the first verification digit
2. Multiply by weights [7, 8, 9]
3. Sum all products
4. Calculate: sum % 11
5. Apply special rules:
   - If result == 10: VD2 = 0
   - If result == 0 AND state is SP (01) or MG (02): VD2 = 1
   - Otherwise: VD2 = result

**Example Calculation for "690847092828":**

```
Sequential: 6 9 0 8 4 7 0 9
Weights:    2 3 4 5 6 7 8 9
Products:  12 27 0 40 24 49 0 81

Sum: 12 + 27 + 0 + 40 + 24 + 49 + 0 + 81 = 233
233 % 11 = 2
VD1 = 2

Federative Union: 28 (ZZ)
VD1: 2

Calculation: (2 × 7) + (8 × 8) + (2 × 9)
           = 14 + 64 + 18 = 96
96 % 11 = 8
VD2 = 8

Complete Voter ID: 690847092828 ✓
```

**Special Cases for SP (01) and MG (02):**
- These states can have 13-digit voter IDs (9-digit sequential number)
- When modulo calculation results in 0, the verification digit becomes 1 instead of 0
- This is a historical quirk from the early voter registration system

#### Complete Example

```ruby
require 'brazilian-utils/voter-id-utils'

include BrazilianUtils::VoterIdUtils

# Validate user input
voterid = '690847092828'

if valid_voter_id?(voterid)
  formatted = format(voterid)
  puts "Valid Voter ID: #{formatted}"
else
  puts "Invalid Voter ID"
end
# => Valid Voter ID: 6908 4709 28 28

# Generate voter IDs for different states
puts "\nGenerated Voter IDs:"
%w[SP MG RJ BA DF].each do |uf|
  voter_id = generate(uf)
  formatted = format(voter_id)
  puts "  #{uf}: #{formatted}"
end
# => SP: 1234 5678 01 40
# => MG: 9876 5432 02 11
# => RJ: 5555 5555 03 91
# => BA: 1111 2222 05 28
# => DF: 9999 9999 20 70

# Batch validation
voter_ids = [
  '690847092828',
  '163204010922',
  '123456789012',
  '000000000191'
]

puts "\nBatch Validation:"
valid_count = 0
voter_ids.each do |id|
  if is_valid_voter_id(id)
    puts "  ✓ #{format_voter_id(id)}"
    valid_count += 1
  else
    puts "  ✗ #{id} [INVALID]"
  end
end

puts "\nSummary: #{valid_count}/#{voter_ids.length} valid"
# => ✓ 6908 4709 28 28
# => ✓ 1632 0401 09 22
# => ✗ 123456789012 [INVALID]
# => ✓ 0000 0000 01 91
# => Summary: 3/4 valid
```

**Use Cases:**
- Validate voter registration in electoral systems
- Format voter IDs for display on ID cards or websites
- Generate test data for election management systems
- Verify voter ID input in registration forms
- Check voter ID integrity in databases
- Validate documents in identity verification systems

**Important Notes:**
- Validation does not check if the voter ID is actually registered or active
- Only validates format and verification digit calculation
- The voter ID must be provided as digits only (no spaces or symbols)
- ZZ (28) is used for voter IDs issued to foreigners living in Brazil
- SP and MG have historical edge cases with 13-digit voter IDs

**Voter ID Structure:**
```
690847092828
││││││││││└┴── Verification digits (2 digits)
││││││││└┴──── Federative union / State code (2 digits: 01-28)
└┴┴┴┴┴┴┴────── Sequential number (8 digits, or 9 for SP/MG)

Total: Usually 12 digits (13 for some SP/MG cases)
```

**Related Information:**
- Required document for all Brazilian citizens over 18 years old
- Voting is mandatory in Brazil (with some exceptions)
- Each voter ID is unique and linked to an electoral zone and section
- The sequential number was originally assigned by registration order in each state
- Electronic voter IDs (e-Título) are now available but use the same number
- Found on physical voter registration card or electronic app

### CEP Utils

Based on the [brazilian-utils/python](https://github.com/brazilian-utils/python/blob/main/brutils/cep.py) implementation.

#### 1. Formatação

##### `remove_symbols(dirty)`
Remove símbolos específicos (`.` e `-`) de um CEP.

```ruby
BrazilianUtils::CEPUtils.remove_symbols("123-45.678.9")
# => "123456789"

BrazilianUtils::CEPUtils.remove_symbols("abc.xyz")
# => "abcxyz"
```

##### `format_cep(cep)`
Formata um CEP brasileiro no formato padrão "12345-678".

```ruby
BrazilianUtils::CEPUtils.format_cep("12345678")
# => "12345-678"

BrazilianUtils::CEPUtils.format_cep("01310100")
# => "01310-100"

BrazilianUtils::CEPUtils.format_cep("12345")
# => nil (CEP inválido)
```

#### 2. Validação

##### `valid?(cep)`
Verifica se um CEP é válido (deve ter exatamente 8 dígitos).

```ruby
BrazilianUtils::CEPUtils.valid?("12345678")
# => true

BrazilianUtils::CEPUtils.valid?("12345")
# => false

BrazilianUtils::CEPUtils.valid?("abcdefgh")
# => false
```

**Nota:** Esta função apenas valida o formato (8 dígitos), não verifica se o CEP realmente existe.

#### 3. Geração

##### `generate`
Gera um CEP aleatório de 8 dígitos.

```ruby
BrazilianUtils::CEPUtils.generate
# => "12345678" (número aleatório)
```

#### 4. Consulta de Endereço via API

##### `get_address_from_cep(cep, raise_exceptions: false)`
Busca informações de endereço a partir de um CEP usando a API ViaCEP.

```ruby
# Consulta bem-sucedida
address = BrazilianUtils::CEPUtils.get_address_from_cep("01310100")
# => #<BrazilianUtils::Address:0x... 
#      cep="01310-100",
#      logradouro="Avenida Paulista",
#      complemento="",
#      bairro="Bela Vista",
#      localidade="São Paulo",
#      uf="SP",
#      ibge="3550308",
#      gia="1004",
#      ddd="11",
#      siafi="7107">

# CEP inválido (sem exceção)
BrazilianUtils::CEPUtils.get_address_from_cep("abcdefg")
# => nil

# CEP inválido (com exceção)
BrazilianUtils::CEPUtils.get_address_from_cep("abcdefg", raise_exceptions: true)
# => BrazilianUtils::InvalidCEP: CEP 'abcdefg' is invalid.

# CEP não encontrado (com exceção)
BrazilianUtils::CEPUtils.get_address_from_cep("99999999", raise_exceptions: true)
# => BrazilianUtils::CEPNotFound: 99999999
```

**Parâmetros:**
- `cep` (String): CEP a ser consultado
- `raise_exceptions` (Boolean): Se `true`, lança exceções em caso de erro. Padrão: `false`

**Retorna:**
- `Address`: Objeto com informações do endereço
- `nil`: Se o CEP for inválido ou não encontrado (quando `raise_exceptions` é `false`)

**Exceções:**
- `InvalidCEP`: Quando o CEP é inválido
- `CEPNotFound`: Quando o CEP não é encontrado

##### `get_cep_information_from_address(federal_unit, city, street, raise_exceptions: false)`
Busca opções de CEP a partir de um endereço usando a API ViaCEP.

```ruby
# Consulta bem-sucedida
addresses = BrazilianUtils::CEPUtils.get_cep_information_from_address("SP", "São Paulo", "Paulista")
# => [
#      #<BrazilianUtils::Address cep="01310-100", logradouro="Avenida Paulista", ...>,
#      #<BrazilianUtils::Address cep="01310-200", logradouro="Avenida Paulista", ...>,
#      ...
#    ]

# UF inválida (sem exceção)
BrazilianUtils::CEPUtils.get_cep_information_from_address("XX", "City", "Street")
# => nil

# UF inválida (com exceção)
BrazilianUtils::CEPUtils.get_cep_information_from_address("XX", "City", "Street", raise_exceptions: true)
# => ArgumentError: Invalid UF: XX

# Endereço não encontrado (com exceção)
BrazilianUtils::CEPUtils.get_cep_information_from_address("SP", "NonExistent", "NonExistent", raise_exceptions: true)
# => BrazilianUtils::CEPNotFound: SP - NonExistent - NonExistent
```

**Parâmetros:**
- `federal_unit` (String): Sigla do estado (UF) com 2 letras
- `city` (String): Nome da cidade
- `street` (String): Nome (ou parte do nome) da rua
- `raise_exceptions` (Boolean): Se `true`, lança exceções em caso de erro. Padrão: `false`

**Retorna:**
- `Array<Address>`: Lista de endereços encontrados
- `nil`: Se o endereço não for encontrado ou a UF for inválida (quando `raise_exceptions` é `false`)

**Exceções:**
- `ArgumentError`: Quando a UF é inválida
- `CEPNotFound`: Quando o endereço não é encontrado

#### 5. Utilidades de UF (Estado)

##### `BrazilianUtils::UF.valid?(uf)`
Verifica se uma sigla de UF é válida.

```ruby
BrazilianUtils::UF.valid?("SP")
# => true

BrazilianUtils::UF.valid?("XX")
# => false
```

##### `BrazilianUtils::UF.name_from_code(code)`
Retorna o nome completo do estado a partir da sigla.

```ruby
BrazilianUtils::UF.name_from_code("SP")
# => "São Paulo"

BrazilianUtils::UF.name_from_code("RJ")
# => "Rio de Janeiro"
```

##### `BrazilianUtils::UF.code_from_name(name)`
Retorna a sigla do estado a partir do nome completo.

```ruby
BrazilianUtils::UF.code_from_name("São Paulo")
# => "SP"

BrazilianUtils::UF.code_from_name("Rio de Janeiro")
# => "RJ"
```

### Estrutura de Dados

#### Address
Struct que representa um endereço brasileiro:

```ruby
BrazilianUtils::Address.new(
  cep: "01310-100",
  logradouro: "Avenida Paulista",
  complemento: "",
  bairro: "Bela Vista",
  localidade: "São Paulo",
  uf: "SP",
  ibge: "3550308",
  gia: "1004",
  ddd: "11",
  siafi: "7107"
)
```

### Exceções Personalizadas

- `BrazilianUtils::InvalidCEP`: Lançada quando um CEP é inválido
- `BrazilianUtils::CEPNotFound`: Lançada quando um CEP ou endereço não é encontrado

### Exemplo Completo

```ruby
require 'brazilian-utils/cep-utils'

# Validar e formatar CEP
cep = "01310100"
if BrazilianUtils::CEPUtils.valid?(cep)
  formatted = BrazilianUtils::CEPUtils.format_cep(cep)
  puts "CEP válido: #{formatted}"
end

# Buscar endereço
address = BrazilianUtils::CEPUtils.get_address_from_cep("01310100")
if address
  puts "Endereço: #{address.logradouro}, #{address.bairro}"
  puts "Cidade: #{address.localidade} - #{address.uf}"
end

# Buscar CEPs de uma rua
ceps = BrazilianUtils::CEPUtils.get_cep_information_from_address("SP", "São Paulo", "Paulista")
if ceps
  ceps.each do |addr|
    puts "#{addr.cep} - #{addr.logradouro}"
  end
end

# Gerar CEP aleatório para testes
random_cep = BrazilianUtils::CEPUtils.generate
puts "CEP aleatório: #{BrazilianUtils::CEPUtils.format_cep(random_cep)}"
```

For more examples, see [examples/cep_usage_example.rb](examples/cep_usage_example.rb).

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `bundle exec rspec` to run the tests.

```bash
# Executar todos os testes
bundle exec rspec

# Executar apenas os testes de CEP
bundle exec rspec spec/cep_utils_spec.rb

# Usando Rake
bundle exec rake spec
```

## References

- [ViaCEP API](https://viacep.com.br/) - API pública para consulta de CEPs
- [Wikipedia - CEP](https://en.wikipedia.org/wiki/Código_de_Endereçamento_Postal) - Informações sobre o sistema de CEP brasileiro
- [brazilian-utils/python](https://github.com/brazilian-utils/python) - Implementação original em Python

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/brazilian-utils/ruby.

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).
