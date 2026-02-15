# :brazil: Brazilian Utils

> Biblioteca de utilitários para dados específicos do Brasil / Utils library for Brazilian-specific data

[![Gem Version](https://badge.fury.io/rb/pipeme.svg)](https://badge.fury.io/rb/br-utils)
![](http://ruby-gem-downloads-badge.herokuapp.com/br-utils)

[🇧🇷 Português](#português) | [🇺🇸 English](#english)

---

## Português

### 📋 Recursos

Utilitários para trabalhar com formatos de dados brasileiros:

- **CPF** - Validação, formatação e geração
- **CNH** - Validação de Carteira Nacional de Habilitação
- **CNPJ** - Validação, formatação e geração
- **CEP** - Validação, formatação e busca via API ViaCEP
- **Moeda** - Formatação de Real (R$) e conversão para extenso
- **Data** - Verificação de feriados e conversão para texto
- **Email** - Validação (RFC 5322)
- **Natureza Jurídica** - Validação de códigos oficiais
- **Processos Judiciais** - Validação, formatação e geração
- **Placas de Veículos** - Validação e conversão (antigo/Mercosul)
- **Telefone** - Validação e formatação (móvel/fixo)
- **PIS** - Validação, formatação e geração (PIS/PASEP)
- **RENAVAM** - Validação de registro de veículos
- **Título de Eleitor** - Validação, formatação e geração

### 💾 Instalação

```ruby
gem 'br-utils'
```

```bash
bundle install
```

### 🚀 Uso Rápido

```ruby
# CPF
require 'brazilian-utils/cpf-utils'
BrazilianUtils::CPFUtils.is_valid('11144477735')  # => true
BrazilianUtils::CPFUtils.format_cpf('11144477735')  # => "111.444.777-35"
BrazilianUtils::CPFUtils.generate  # => "12345678901"

# CNPJ
require 'brazilian-utils/cnpj-utils'
BrazilianUtils::CNPJUtils.is_valid('34665388000161')  # => true
BrazilianUtils::CNPJUtils.format_cnpj('34665388000161')  # => "34.665.388/0001-61"

# CEP
require 'brazilian-utils/cep-utils'
BrazilianUtils::CEPUtils.format_cep('01310100')  # => "01310-100"
BrazilianUtils::CEPUtils.get_address('01310100')  # => {...endereço completo...}

# Telefone
require 'brazilian-utils/phone-utils'
BrazilianUtils::PhoneUtils.is_valid('11987654321')  # => true
BrazilianUtils::PhoneUtils.format('11987654321')  # => "(11)98765-4321"

# Placa de Veículo
require 'brazilian-utils/license-plate-utils'
BrazilianUtils::LicensePlateUtils.is_valid('ABC1234')  # => true
BrazilianUtils::LicensePlateUtils.convert_to_mercosul('ABC1234')  # => "ABC1C34"

# Título de Eleitor
require 'brazilian-utils/voter-id-utils'
BrazilianUtils::VoterIdUtils.is_valid_voter_id('690847092828')  # => true
BrazilianUtils::VoterIdUtils.format('690847092828')  # => "6908 4709 28 28"
BrazilianUtils::VoterIdUtils.generate('SP')  # => "123456780140"

# Moeda
require 'brazilian-utils/currency-utils'
BrazilianUtils::CurrencyUtils.format_currency(1234.56)  # => "R$ 1.234,56"
BrazilianUtils::CurrencyUtils.number_to_text(1234.56)  # => "mil duzentos e trinta e quatro reais..."
```

### 📚 Documentação Detalhada

Para exemplos completos de cada utilitário, consulte a pasta [`examples/`](examples/).

**Principais Módulos:**
- [`CPFUtils`](lib/brazilian-utils/cpf-utils.rb) - Validação e formatação de CPF
- [`CNPJUtils`](lib/brazilian-utils/cnpj-utils.rb) - Validação e formatação de CNPJ
- [`CEPUtils`](lib/brazilian-utils/cep-utils.rb) - Validação de CEP e busca de endereços
- [`PhoneUtils`](lib/brazilian-utils/phone-utils.rb) - Validação de telefones
- [`LicensePlateUtils`](lib/brazilian-utils/license-plate-utils.rb) - Placas de veículos
- [`VoterIdUtils`](lib/brazilian-utils/voter-id-utils.rb) - Títulos de eleitor
- [`CurrencyUtils`](lib/brazilian-utils/currency-utils.rb) - Formatação de moeda
- [`DateUtils`](lib/brazilian-utils/date-utils.rb) - Feriados e datas por extenso
- [`EmailUtils`](lib/brazilian-utils/email-utils.rb) - Validação de email
- [`LegalNatureUtils`](lib/brazilian-utils/legal-nature-utils.rb) - Natureza jurídica
- [`LegalProcessUtils`](lib/brazilian-utils/legal-process-utils.rb) - Processos judiciais
- [`PISUtils`](lib/brazilian-utils/pis-utils.rb) - PIS/PASEP
- [`RENAVAMUtils`](lib/brazilian-utils/renavam-utils.rb) - RENAVAM
- [`CNHUtils`](lib/brazilian-utils/cnh-utils.rb) - CNH

---

## English

### 📋 Features

Utilities for working with Brazilian data formats:

- **CPF** - Validation, formatting, and generation
- **CNH** - Driver's license validation
- **CNPJ** - Company tax ID validation, formatting, and generation
- **CEP** - Postal code validation, formatting, and address lookup (ViaCEP API)
- **Currency** - Brazilian Real (R$) formatting and text conversion
- **Date** - Holiday checking and date-to-text conversion
- **Email** - Email validation (RFC 5322)
- **Legal Nature** - Official business entity code validation
- **Legal Process** - Judicial process ID validation, formatting, and generation
- **License Plate** - Vehicle plate validation and format conversion (old/Mercosul)
- **Phone** - Mobile and landline validation and formatting
- **PIS** - Social security number validation, formatting, and generation
- **RENAVAM** - Vehicle registration validation
- **Voter ID** - Voter registration validation, formatting, and generation

### 💾 Installation

```ruby
gem 'br-utils'
```

```bash
bundle install
```

### 🚀 Quick Start

```ruby
# CPF
require 'brazilian-utils/cpf-utils'
BrazilianUtils::CPFUtils.is_valid('11144477735')  # => true
BrazilianUtils::CPFUtils.format_cpf('11144477735')  # => "111.444.777-35"
BrazilianUtils::CPFUtils.generate  # => "12345678901"

# CNPJ
require 'brazilian-utils/cnpj-utils'
BrazilianUtils::CNPJUtils.is_valid('34665388000161')  # => true
BrazilianUtils::CNPJUtils.format_cnpj('34665388000161')  # => "34.665.388/0001-61"

# CEP (Postal Code)
require 'brazilian-utils/cep-utils'
BrazilianUtils::CEPUtils.format_cep('01310100')  # => "01310-100"
BrazilianUtils::CEPUtils.get_address('01310100')  # => {...complete address...}

# Phone
require 'brazilian-utils/phone-utils'
BrazilianUtils::PhoneUtils.is_valid('11987654321')  # => true
BrazilianUtils::PhoneUtils.format('11987654321')  # => "(11)98765-4321"

# License Plate
require 'brazilian-utils/license-plate-utils'
BrazilianUtils::LicensePlateUtils.is_valid('ABC1234')  # => true
BrazilianUtils::LicensePlateUtils.convert_to_mercosul('ABC1234')  # => "ABC1C34"

# Voter ID
require 'brazilian-utils/voter-id-utils'
BrazilianUtils::VoterIdUtils.is_valid_voter_id('690847092828')  # => true
BrazilianUtils::VoterIdUtils.format('690847092828')  # => "6908 4709 28 28"
BrazilianUtils::VoterIdUtils.generate('SP')  # => "123456780140"

# Currency
require 'brazilian-utils/currency-utils'
BrazilianUtils::CurrencyUtils.format_currency(1234.56)  # => "R$ 1.234,56"
BrazilianUtils::CurrencyUtils.number_to_text(1234.56)  # => "mil duzentos e trinta e quatro reais..."
```

### 📚 Full Documentation

For detailed examples of each utility, check the [`examples/`](examples/) folder.

**Main Modules:**
- [`CPFUtils`](lib/brazilian-utils/cpf-utils.rb) - CPF validation and formatting
- [`CNPJUtils`](lib/brazilian-utils/cnpj-utils.rb) - CNPJ validation and formatting
- [`CEPUtils`](lib/brazilian-utils/cep-utils.rb) - CEP validation and address lookup
- [`PhoneUtils`](lib/brazilian-utils/phone-utils.rb) - Phone validation
- [`LicensePlateUtils`](lib/brazilian-utils/license-plate-utils.rb) - Vehicle plates
- [`VoterIdUtils`](lib/brazilian-utils/voter-id-utils.rb) - Voter IDs
- [`CurrencyUtils`](lib/brazilian-utils/currency-utils.rb) - Currency formatting
- [`DateUtils`](lib/brazilian-utils/date-utils.rb) - Holidays and date text
- [`EmailUtils`](lib/brazilian-utils/email-utils.rb) - Email validation
- [`LegalNatureUtils`](lib/brazilian-utils/legal-nature-utils.rb) - Legal nature codes
- [`LegalProcessUtils`](lib/brazilian-utils/legal-process-utils.rb) - Legal process IDs
- [`PISUtils`](lib/brazilian-utils/pis-utils.rb) - PIS/PASEP
- [`RENAVAMUtils`](lib/brazilian-utils/renavam-utils.rb) - Vehicle registration
- [`CNHUtils`](lib/brazilian-utils/cnh-utils.rb) - Driver's license

---

## 🧪 Development

```bash
# Install dependencies
bundle install

# Run tests
bundle exec rspec

# Run specific test
bundle exec rspec spec/cpf_utils_spec.rb
```

## 📖 API Reference

### Common Patterns

Most utilities follow these patterns:

**Validation:**
```ruby
.is_valid(value)      # Main validation method
.valid?(value)        # Alias for is_valid
```

**Formatting:**
```ruby
.format(value)        # Format with standard symbols
.remove_symbols(value) # Remove formatting symbols
```

**Generation:**
```ruby
.generate             # Generate random valid value
```

### Utility-Specific Methods

**CEP:**
- `get_address(cep)` - Fetch address from CEP
- `get_cep_information_from_address(uf, city, street)` - Find CEPs

**Phone:**
- `is_valid(phone, type:)` - Validate with type (:mobile or :landline)
- `remove_international_dialing_code(phone)` - Remove +55/55

**License Plate:**
- `convert_to_mercosul(plate)` - Convert old format to Mercosul
- `get_format(plate)` - Detect format ("LLLNNNN" or "LLLNLNN")

**Voter ID:**
- `generate(uf)` - Generate for specific state

**Currency:**
- `format_currency(value)` - Format as R$ X.XXX,XX
- `number_to_text(value)` - Convert to Brazilian Portuguese text

**Date:**
- `is_holiday(date, uf)` - Check if date is holiday
- `convert_date_to_text(date)` - Convert to Portuguese text

**Legal Nature:**
- `get_description(code)` - Get description for code
- `list_by_category(category)` - List codes by category (1-5)

**Legal Process:**
- `generate(year, orgao)` - Generate for specific year and judicial segment

## 📊 Examples by Use Case

### Form Validation

```ruby
# Validate user input
cpf = params[:cpf]
if BrazilianUtils::CPFUtils.valid?(cpf)
  # Process valid CPF
else
  errors.add(:cpf, "inválido")
end
```

### Display Formatting

```ruby
# Format for display
cpf = "11144477735"
formatted = BrazilianUtils::CPFUtils.format_cpf(cpf)
puts formatted  # => "111.444.777-35"
```

### Test Data Generation

```ruby
# Generate test data
10.times do
  cpf = BrazilianUtils::CPFUtils.generate
  puts BrazilianUtils::CPFUtils.format_cpf(cpf)
end
```

### API Integration

```ruby
# Lookup address from CEP
address = BrazilianUtils::CEPUtils.get_address('01310100')
if address
  puts "#{address.logradouro}, #{address.bairro}"
  puts "#{address.localidade} - #{address.uf}"
end
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests.

**Como contribuir / How to contribute:**

1. Fork o projeto / Fork the project
2. Crie seu branch (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para o branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request / Open a Pull Request

## 📄 License

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE.txt](LICENSE.txt) para detalhes.

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details.

## 🙏 Acknowledgments

Baseado na implementação Python: [brazilian-utils/python](https://github.com/brazilian-utils/python)

Based on the Python implementation: [brazilian-utils/python](https://github.com/brazilian-utils/python)

## 📞 Support

- 🐛 **Issues:** [GitHub Issues](https://github.com/brazilian-utils/ruby/issues)
- 📖 **Documentation:** [examples/](examples/) folder
- 💬 **Discussions:** [GitHub Discussions](https://github.com/brazilian-utils/ruby/discussions)

---

<div align="center">
Made with ❤️ for the Brazilian Ruby community
</div>
