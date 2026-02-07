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
