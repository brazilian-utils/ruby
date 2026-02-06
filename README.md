# :brazil: Brazilian Utils
> Utils library for specific Brazilian businesses.

[![Gem Version](https://badge.fury.io/rb/pipeme.svg)](https://badge.fury.io/rb/brazilian-utils)
![](http://ruby-gem-downloads-badge.herokuapp.com/brazilian-utils)
[![Build Status](https://travis-ci.org/brazilian-utils/ruby.svg?branch=master)](https://travis-ci.org/brazilian-utils/ruby)

## Features

This library provides utilities for working with Brazilian-specific data formats:

### CPF Utils
- CPF validation

### CNH Utils
- CNH validation (Carteira Nacional de Habilitação)

### CNPJ Utils
- CNPJ validation (Cadastro Nacional da Pessoa Jurídica)
- CNPJ formatting and symbol removal
- Random CNPJ generation

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

```ruby
require 'brazilian-utils/cpf-utils'

BrazilianUtils::CPFUtils.valid?('41840660546')
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
