# :brazil: Brazilian Utils
> Utils library for specific Brazilian businesses.

[![Gem Version](https://badge.fury.io/rb/pipeme.svg)](https://badge.fury.io/rb/brazilian-utils)
![](http://ruby-gem-downloads-badge.herokuapp.com/brazilian-utils)
[![Build Status](https://travis-ci.org/brazilian-utils/ruby.svg?branch=master)](https://travis-ci.org/brazilian-utils/ruby)

## Features

This library provides utilities for working with Brazilian-specific data formats:

### CPF Utils
- CPF validation

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
