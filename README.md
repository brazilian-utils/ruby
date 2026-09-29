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
- **CNS** - Validação e formatação do Cartão Nacional de Saúde
- **Passaporte** - Validação, formatação e geração de números de passaporte
- **Certidão de Registro Civil** - Validação e extração de dados da matrícula (nascimento/casamento/óbito)
- **Registro Profissional** - Validação de OAB, CRM, CRO, CRP e CRC
- **CNPJ** - Validação, formatação e geração (v1 numérico e v2 alfanumérico)
- **Inscrição Estadual (IE)** - Validação por UF
- **CEP** - Validação, formatação e busca via API ViaCEP
- **Moeda** - Formatação de Real (R$) e conversão para extenso
- **Bancos** - Consulta de instituições financeiras (código COMPE/ISPB)
- **Conta Bancária** - Validação estrutural de agência e conta
- **IBAN** - Validação, formatação e extração de dados do IBAN brasileiro
- **Cartão de Crédito/Débito** - Validação via algoritmo de Luhn
- **Chave Pix** - Identificação e validação de chaves Pix (CPF/CNPJ/email/telefone/EVP)
- **Payload Pix** - Validação, leitura e geração de BR Code (Pix Copia e Cola)
- **Data** - Verificação de feriados, dias úteis e conversão para texto
- **Email** - Validação (RFC 5322)
- **Natureza Jurídica** - Validação de códigos oficiais
- **Processos Judiciais** - Validação, formatação e geração
- **CAEPF** - Validação, formatação e extração de dados
- **CNO** - Validação e formatação do Cadastro Nacional de Obras
- **CEI** - Validação e formatação de CEI
- **CBO** - Validação e consulta da Classificação Brasileira de Ocupações
- **CFOP** - Validação e consulta do Código Fiscal de Operações e Prestações
- **CNAE** - Validação, formatação e consulta de atividade econômica
- **NCM** - Validação e formatação da Nomenclatura Comum do Mercosul
- **CSOSN** - Validação de código de situação da operação no Simples Nacional
- **CST** - Validação de Código de Situação Tributária (ICMS/IPI/PIS-COFINS)
- **Placas de Veículos** - Validação e conversão (antigo/Mercosul)
- **VIN/Chassi** - Validação de número de chassi (VIN)
- **Telefone** - Validação e formatação (móvel/fixo)
- **PIS** - Validação, formatação e geração (PIS/PASEP)
- **RENAVAM** - Validação de registro de veículos
- **Título de Eleitor** - Validação, formatação e geração
- **DDD** - Consulta de código de área por estado
- **Estados (UF)** - Consulta de estado, região e fuso horário
- **Municípios** - Consulta de municípios por código IBGE
- **Chave de Acesso NF-e/DF-e** - Validação, formatação e extração de dados
- **Números por Extenso** - Conversão de números para texto
- **Texto** - Capitalização e remoção de acentos

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

# CNS (Cartão Nacional de Saúde)
require 'brazilian-utils/cns-utils'
BrazilianUtils::CNSUtils.is_valid('123456789010000')  # => true
BrazilianUtils::CNSUtils.format('123456789010001')  # => "123 4567 8901 0001"

# Passaporte
require 'brazilian-utils/passport-utils'
BrazilianUtils::PassportUtils.is_valid('CL125167')  # => true
BrazilianUtils::PassportUtils.format('acd12736')  # => "ACD12736"
BrazilianUtils::PassportUtils.generate  # => "LB809567"

# Certidão de Registro Civil
require 'brazilian-utils/certidao-utils'
BrazilianUtils::CertidaoUtils.is_valid('10453901552013100012021000012321')  # => true
BrazilianUtils::CertidaoUtils.format('10453901552013100012021000012321')
# => "104539 01 55 2013 1 00012 021 0000123 21"
BrazilianUtils::CertidaoUtils.get_info('10453901552013100012021000012321')
# => {registryCns: "104539", acervo: "01", service: "55", year: 2013, type: "birth", ...}

# Registro Profissional (OAB/CRM/CRO/CRP/CRC)
require 'brazilian-utils/registro-profissional-utils'
BrazilianUtils::RegistroProfissionalUtils.is_valid(value: '123456/SP', council: 'OAB')  # => true
BrazilianUtils::RegistroProfissionalUtils.is_valid(value: '06/12345', council: 'CRP')  # => true

# CNPJ
require 'brazilian-utils/cnpj-utils'
BrazilianUtils::CNPJUtils.is_valid('34665388000161')  # => true
BrazilianUtils::CNPJUtils.format_cnpj('34665388000161')  # => "34.665.388/0001-61"
# CNPJ v2 (alfanumérico, IN RFB 2.119)
BrazilianUtils::CNPJUtils.valid?('12ABC345000188', version: 2)  # => true
BrazilianUtils::CNPJUtils.generate(version: 2)  # => "12ABC345000188" (alfanumérico)

# Inscrição Estadual (IE)
require 'brazilian-utils/ie-utils'
BrazilianUtils::IEUtils.is_valid('110042490114', 'SP')  # => true
BrazilianUtils::IEUtils.is_valid('12345678', 'RJ')  # => true

# CEP
require 'brazilian-utils/cep-utils'
BrazilianUtils::CEPUtils.format_cep('01310100')  # => "01310-100"
BrazilianUtils::CEPUtils.get_address('01310100')  # => {...endereço completo...}

# Moeda
require 'brazilian-utils/currency-utils'
BrazilianUtils::CurrencyUtils.format_currency(1234.56)  # => "1.234,56"
BrazilianUtils::CurrencyUtils.number_to_text(1234.56)  # => "mil duzentos e trinta e quatro reais..."

# Bancos
require 'brazilian-utils/bank-utils'
BrazilianUtils::BankUtils.get_by_code('341')  # => {code: "341", ispb: "60701190", name: "ITAÚ UNIBANCO S.A."}
BrazilianUtils::BankUtils.get_by_ispb('00000000')  # => {code: "001", ispb: "00000000", name: "Banco do Brasil S.A."}

# Conta Bancária
require 'brazilian-utils/bank-account-utils'
BrazilianUtils::BankAccountUtils.is_valid(bankCode: '001', agency: '1234', account: '123456', digit: 'X')  # => true

# IBAN
require 'brazilian-utils/iban-utils'
BrazilianUtils::IBANUtils.is_valid('BR1500000000000010932840814P2')  # => true
BrazilianUtils::IBANUtils.format('BR1500000000000010932840814P2')
# => "BR15 0000 0000 0000 1093 2840 814P 2"

# Cartão de Crédito/Débito
require 'brazilian-utils/credit-card-utils'
BrazilianUtils::CreditCardUtils.is_valid('4111111111111111')  # => true (Visa)
BrazilianUtils::CreditCardUtils.is_valid('4111111111111112')  # => false (falha no dígito de Luhn)

# Chave Pix
require 'brazilian-utils/pix-key-utils'
BrazilianUtils::PixKeyUtils.is_valid('123.456.789-09')  # => true
BrazilianUtils::PixKeyUtils.get_info('123.456.789-09')  # => {type: "cpf", value: "12345678909"}

# Payload Pix (BR Code)
require 'brazilian-utils/pix-payload-utils'
payload = BrazilianUtils::PixPayloadUtils.generate(
  key: '123.456.789-09', merchantName: 'Fulano de Tal', merchantCity: 'Brasília'
)
BrazilianUtils::PixPayloadUtils.is_valid(payload)  # => true
BrazilianUtils::PixPayloadUtils.get_info(payload)
# => {merchantName: "Fulano de Tal", merchantCity: "Brasilia", pointOfInitiation: "static", key: "12345678909"}

# Data
require 'brazilian-utils/date-utils'
BrazilianUtils::DateUtils.is_holiday(Date.new(2024, 1, 1))  # => true
BrazilianUtils::DateUtils.is_business_day(Date.new(2024, 3, 4))  # => true
BrazilianUtils::DateUtils.add_business_days(Date.new(2024, 3, 1), 1)  # => #<Date: 2024-03-04>

# CAEPF
require 'brazilian-utils/caepf-utils'
BrazilianUtils::CAEPFUtils.is_valid('293.118.610/001-84')  # => true
BrazilianUtils::CAEPFUtils.format('29311861000184')  # => "293.118.610/001-84"

# CNO
require 'brazilian-utils/cno-utils'
BrazilianUtils::CNOUtils.is_valid('11.084.01680/62')  # => true
BrazilianUtils::CNOUtils.format('111130137368')  # => "11.113.01373/68"

# CEI
require 'brazilian-utils/cei-utils'
BrazilianUtils::CEIUtils.is_valid('11.583.00249/85')  # => true
BrazilianUtils::CEIUtils.format('277297118187')  # => "27.729.71181/87"

# CBO
require 'brazilian-utils/cbo-utils'
BrazilianUtils::CBOUtils.is_valid('2124-05')  # => true
BrazilianUtils::CBOUtils.get('212405')  # => {code: "212405", description: "Analista de desenvolvimento de sistemas"}

# CFOP
require 'brazilian-utils/cfop-utils'
BrazilianUtils::CFOPUtils.is_valid('5102')  # => true
BrazilianUtils::CFOPUtils.get('5102')[:description]  # => "Venda de mercadoria adquirida ou recebida de terceiros..."

# CNAE
require 'brazilian-utils/cnae-utils'
BrazilianUtils::CNAEUtils.is_valid('6201-5/01')  # => true
BrazilianUtils::CNAEUtils.get('6201501')
# => {code: "6201501", description: "DESENVOLVIMENTO DE PROGRAMAS DE COMPUTADOR SOB ENCOMENDA"}

# NCM
require 'brazilian-utils/ncm-utils'
BrazilianUtils::NCMUtils.is_valid('2203.00.00')  # => true
BrazilianUtils::NCMUtils.format('84713012')  # => "8471.30.12"

# CSOSN
require 'brazilian-utils/csosn-utils'
BrazilianUtils::CSOSNUtils.is_valid('101')  # => true
BrazilianUtils::CSOSNUtils.get_description('101')  # => "Tributada pelo Simples Nacional com permissão de crédito"

# CST (ICMS/IPI/PIS-COFINS)
require 'brazilian-utils/cst-utils'
BrazilianUtils::CSTUtils.is_valid('110')  # => true (ICMS)
BrazilianUtils::CSTUtils.is_valid('07', tax: 'pis')  # => true

# Placa de Veículo
require 'brazilian-utils/license-plate-utils'
BrazilianUtils::LicensePlateUtils.is_valid('ABC1234')  # => true
BrazilianUtils::LicensePlateUtils.convert_to_mercosul('ABC1234')  # => "ABC1C34"

# VIN (Chassi)
require 'brazilian-utils/vin-utils'
BrazilianUtils::VINUtils.is_valid('1HGCM82633A004352')  # => true
BrazilianUtils::VINUtils.is_valid('1M8GDM9AXKP042788')  # => true (dígito verificador X)

# Telefone
require 'brazilian-utils/phone-utils'
BrazilianUtils::PhoneUtils.is_valid('11987654321')  # => true
BrazilianUtils::PhoneUtils.format('987654321')  # => "98765-4321"
BrazilianUtils::PhoneUtils.format('11987654321', mask: :ddd)  # => "(11) 98765-4321"

# Título de Eleitor
require 'brazilian-utils/voter-id-utils'
BrazilianUtils::VoterIdUtils.is_valid_voter_id('690847092828')  # => true
BrazilianUtils::VoterIdUtils.format('690847092828')  # => "6908 4709 28 28"
BrazilianUtils::VoterIdUtils.generate('SP')  # => "123456780140"

# DDD
require 'brazilian-utils/area-code-utils'
BrazilianUtils::AreaCodeUtils.get_info('11')
# => {areaCode: 11, stateCode: "SP", stateName: "São Paulo", regionCode: "SE", regionName: "Sudeste", stateCodes: ["SP"]}
BrazilianUtils::AreaCodeUtils.list_by_state('SP')  # => [11, 12, 13, 14, 15, 16, 17, 18, 19]

# Estados (UF)
require 'brazilian-utils/state-utils'
BrazilianUtils::StateUtils.get_by_ibge_code('35')
# => {code: "SP", name: "São Paulo", regionCode: "SE", regionName: "Sudeste", ibgeCode: 35}
BrazilianUtils::StateUtils.get_timezone('AM')  # => "America/Manaus"

# Municípios
require 'brazilian-utils/municipality-utils'
BrazilianUtils::MunicipalityUtils.get_by_code('3550308')  # => {code: "3550308", name: "São Paulo", stateCode: "SP"}
BrazilianUtils::MunicipalityUtils.list('DF')  # => [{code: "5300108", name: "Brasília", stateCode: "DF"}]

# Chave de Acesso NF-e/DF-e
require 'brazilian-utils/nfe-key-utils'
BrazilianUtils::NfeKeyUtils.is_valid('35170458716523000119550010000000121000123458')  # => true
BrazilianUtils::NfeKeyUtils.format('35170458716523000119550010000000121000123458')
# => "3517 0458 7165 2300 0119 5500 1000 0000 1210 0012 3458"

# Números por Extenso
require 'brazilian-utils/number-utils'
BrazilianUtils::NumberUtils.convert_to_words(123)  # => "cento e vinte e três"
BrazilianUtils::NumberUtils.convert_to_words(1, gender: :feminine)  # => "uma"

# Texto
require 'brazilian-utils/text-utils'
BrazilianUtils::TextUtils.capitalize('fulano de tal')  # => "Fulano de Tal"
BrazilianUtils::TextUtils.remove_accents('São Paulo')  # => "Sao Paulo"
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
- [`TextUtils`](lib/brazilian-utils/text-utils.rb) - Capitalização e remoção de acentos
- [`NumberUtils`](lib/brazilian-utils/number-utils.rb) - Números por extenso
- [`StateUtils`](lib/brazilian-utils/state-utils.rb) - Estados brasileiros (UF)
- [`AreaCodeUtils`](lib/brazilian-utils/area-code-utils.rb) - DDDs
- [`BankUtils`](lib/brazilian-utils/bank-utils.rb) - Bancos (código COMPE/ISPB)
- [`BankAccountUtils`](lib/brazilian-utils/bank-account-utils.rb) - Contas bancárias
- [`MunicipalityUtils`](lib/brazilian-utils/municipality-utils.rb) - Municípios (código IBGE)
- [`CFOPUtils`](lib/brazilian-utils/cfop-utils.rb) - CFOP
- [`CNAEUtils`](lib/brazilian-utils/cnae-utils.rb) - CNAE
- [`CBOUtils`](lib/brazilian-utils/cbo-utils.rb) - CBO
- [`NCMUtils`](lib/brazilian-utils/ncm-utils.rb) - NCM
- [`CSOSNUtils`](lib/brazilian-utils/csosn-utils.rb) - CSOSN
- [`CSTUtils`](lib/brazilian-utils/cst-utils.rb) - CST (ICMS/IPI/PIS-COFINS)
- [`CEIUtils`](lib/brazilian-utils/cei-utils.rb) - CEI
- [`CNOUtils`](lib/brazilian-utils/cno-utils.rb) - CNO
- [`CNSUtils`](lib/brazilian-utils/cns-utils.rb) - Cartão Nacional de Saúde
- [`CAEPFUtils`](lib/brazilian-utils/caepf-utils.rb) - CAEPF
- [`CertidaoUtils`](lib/brazilian-utils/certidao-utils.rb) - Certidão de registro civil
- [`CreditCardUtils`](lib/brazilian-utils/credit-card-utils.rb) - Cartão de crédito/débito (Luhn)
- [`VINUtils`](lib/brazilian-utils/vin-utils.rb) - Chassi (VIN)
- [`PassportUtils`](lib/brazilian-utils/passport-utils.rb) - Passaporte
- [`IBANUtils`](lib/brazilian-utils/iban-utils.rb) - IBAN brasileiro
- [`NfeKeyUtils`](lib/brazilian-utils/nfe-key-utils.rb) - Chave de acesso NF-e/DF-e
- [`PixKeyUtils`](lib/brazilian-utils/pix-key-utils.rb) - Chave Pix
- [`PixPayloadUtils`](lib/brazilian-utils/pix-payload-utils.rb) - Payload Pix (BR Code)
- [`RegistroProfissionalUtils`](lib/brazilian-utils/registro-profissional-utils.rb) - OAB/CRM/CRO/CRP/CRC
- [`IEUtils`](lib/brazilian-utils/ie-utils.rb) - Inscrição Estadual (IE)
- [`BoletoUtils`](lib/brazilian-utils/boleto-utils.rb) - Boleto bancário

---

## English

### 📋 Features

Utilities for working with Brazilian data formats:

- **CPF** - Validation, formatting, and generation
- **CNH** - Driver's license validation
- **CNS** - National Health Card (Cartão Nacional de Saúde) validation and formatting
- **Passport** - Validation, formatting, and generation of passport numbers
- **Civil Registry Certificate** - Validation and field extraction for registration numbers (birth/marriage/death)
- **Professional Registration** - Validation for OAB, CRM, CRO, CRP, and CRC councils
- **CNPJ** - Company tax ID validation, formatting, and generation (v1 numeric and v2 alphanumeric)
- **State Registration (IE)** - Validation per state (UF)
- **CEP** - Postal code validation, formatting, and address lookup (ViaCEP API)
- **Currency** - Brazilian Real (R$) formatting and text conversion
- **Banks** - Financial institution lookup (COMPE/ISPB code)
- **Bank Account** - Structural agency and account validation
- **IBAN** - Validation, formatting, and field extraction for the Brazilian IBAN
- **Credit/Debit Card** - Luhn algorithm validation
- **Pix Key** - Identification and validation of Pix keys (CPF/CNPJ/email/phone/EVP)
- **Pix Payload** - Validation, parsing, and generation of BR Code (Pix Copy and Paste)
- **Date** - Holiday checking, business-day calculations, and date-to-text conversion
- **Email** - Email validation (RFC 5322)
- **Legal Nature** - Official business entity code validation
- **Legal Process** - Judicial process ID validation, formatting, and generation
- **CAEPF** - Validation, formatting, and field extraction
- **CNO** - National Construction Registry validation and formatting
- **CEI** - Validation and formatting
- **CBO** - Brazilian Occupation Classification validation and lookup
- **CFOP** - Tax Operation Code validation and lookup
- **CNAE** - Economic activity code validation, formatting, and lookup
- **NCM** - Mercosul Common Nomenclature validation and formatting
- **CSOSN** - Simples Nacional tax situation code validation
- **CST** - Tax Situation Code validation (ICMS/IPI/PIS-COFINS)
- **License Plate** - Vehicle plate validation and format conversion (old/Mercosul)
- **VIN/Chassis** - Vehicle identification number (VIN) validation
- **Phone** - Mobile and landline validation and formatting
- **PIS** - Social security number validation, formatting, and generation
- **RENAVAM** - Vehicle registration validation
- **Voter ID** - Voter registration validation, formatting, and generation
- **Area Code** - DDD lookup by state
- **States (UF)** - State, region, and timezone lookup
- **Municipalities** - Municipality lookup by IBGE code
- **NF-e/DF-e Access Key** - Validation, formatting, and field extraction
- **Number to Words** - Convert numbers to text
- **Text** - Capitalization and accent removal

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

# CNS (National Health Card)
require 'brazilian-utils/cns-utils'
BrazilianUtils::CNSUtils.is_valid('123456789010000')  # => true
BrazilianUtils::CNSUtils.format('123456789010001')  # => "123 4567 8901 0001"

# Passport
require 'brazilian-utils/passport-utils'
BrazilianUtils::PassportUtils.is_valid('CL125167')  # => true
BrazilianUtils::PassportUtils.format('acd12736')  # => "ACD12736"
BrazilianUtils::PassportUtils.generate  # => "LB809567"

# Civil Registry Certificate
require 'brazilian-utils/certidao-utils'
BrazilianUtils::CertidaoUtils.is_valid('10453901552013100012021000012321')  # => true
BrazilianUtils::CertidaoUtils.format('10453901552013100012021000012321')
# => "104539 01 55 2013 1 00012 021 0000123 21"
BrazilianUtils::CertidaoUtils.get_info('10453901552013100012021000012321')
# => {registryCns: "104539", acervo: "01", service: "55", year: 2013, type: "birth", ...}

# Professional Registration (OAB/CRM/CRO/CRP/CRC)
require 'brazilian-utils/registro-profissional-utils'
BrazilianUtils::RegistroProfissionalUtils.is_valid(value: '123456/SP', council: 'OAB')  # => true
BrazilianUtils::RegistroProfissionalUtils.is_valid(value: '06/12345', council: 'CRP')  # => true

# CNPJ
require 'brazilian-utils/cnpj-utils'
BrazilianUtils::CNPJUtils.is_valid('34665388000161')  # => true
BrazilianUtils::CNPJUtils.format_cnpj('34665388000161')  # => "34.665.388/0001-61"
# CNPJ v2 (alphanumeric, IN RFB 2.119)
BrazilianUtils::CNPJUtils.valid?('12ABC345000188', version: 2)  # => true
BrazilianUtils::CNPJUtils.generate(version: 2)  # => "12ABC345000188" (alphanumeric)

# State Registration (IE)
require 'brazilian-utils/ie-utils'
BrazilianUtils::IEUtils.is_valid('110042490114', 'SP')  # => true
BrazilianUtils::IEUtils.is_valid('12345678', 'RJ')  # => true

# CEP (Postal Code)
require 'brazilian-utils/cep-utils'
BrazilianUtils::CEPUtils.format_cep('01310100')  # => "01310-100"
BrazilianUtils::CEPUtils.get_address('01310100')  # => {...complete address...}

# Currency
require 'brazilian-utils/currency-utils'
BrazilianUtils::CurrencyUtils.format_currency(1234.56)  # => "1.234,56"
BrazilianUtils::CurrencyUtils.number_to_text(1234.56)  # => "mil duzentos e trinta e quatro reais..."

# Banks
require 'brazilian-utils/bank-utils'
BrazilianUtils::BankUtils.get_by_code('341')  # => {code: "341", ispb: "60701190", name: "ITAÚ UNIBANCO S.A."}
BrazilianUtils::BankUtils.get_by_ispb('00000000')  # => {code: "001", ispb: "00000000", name: "Banco do Brasil S.A."}

# Bank Account
require 'brazilian-utils/bank-account-utils'
BrazilianUtils::BankAccountUtils.is_valid(bankCode: '001', agency: '1234', account: '123456', digit: 'X')  # => true

# IBAN
require 'brazilian-utils/iban-utils'
BrazilianUtils::IBANUtils.is_valid('BR1500000000000010932840814P2')  # => true
BrazilianUtils::IBANUtils.format('BR1500000000000010932840814P2')
# => "BR15 0000 0000 0000 1093 2840 814P 2"

# Credit/Debit Card
require 'brazilian-utils/credit-card-utils'
BrazilianUtils::CreditCardUtils.is_valid('4111111111111111')  # => true (Visa)
BrazilianUtils::CreditCardUtils.is_valid('4111111111111112')  # => false (Luhn check digit fails)

# Pix Key
require 'brazilian-utils/pix-key-utils'
BrazilianUtils::PixKeyUtils.is_valid('123.456.789-09')  # => true
BrazilianUtils::PixKeyUtils.get_info('123.456.789-09')  # => {type: "cpf", value: "12345678909"}

# Pix Payload (BR Code)
require 'brazilian-utils/pix-payload-utils'
payload = BrazilianUtils::PixPayloadUtils.generate(
  key: '123.456.789-09', merchantName: 'Fulano de Tal', merchantCity: 'Brasília'
)
BrazilianUtils::PixPayloadUtils.is_valid(payload)  # => true
BrazilianUtils::PixPayloadUtils.get_info(payload)
# => {merchantName: "Fulano de Tal", merchantCity: "Brasilia", pointOfInitiation: "static", key: "12345678909"}

# Date
require 'brazilian-utils/date-utils'
BrazilianUtils::DateUtils.is_holiday(Date.new(2024, 1, 1))  # => true
BrazilianUtils::DateUtils.is_business_day(Date.new(2024, 3, 4))  # => true
BrazilianUtils::DateUtils.add_business_days(Date.new(2024, 3, 1), 1)  # => #<Date: 2024-03-04>

# CAEPF
require 'brazilian-utils/caepf-utils'
BrazilianUtils::CAEPFUtils.is_valid('293.118.610/001-84')  # => true
BrazilianUtils::CAEPFUtils.format('29311861000184')  # => "293.118.610/001-84"

# CNO
require 'brazilian-utils/cno-utils'
BrazilianUtils::CNOUtils.is_valid('11.084.01680/62')  # => true
BrazilianUtils::CNOUtils.format('111130137368')  # => "11.113.01373/68"

# CEI
require 'brazilian-utils/cei-utils'
BrazilianUtils::CEIUtils.is_valid('11.583.00249/85')  # => true
BrazilianUtils::CEIUtils.format('277297118187')  # => "27.729.71181/87"

# CBO
require 'brazilian-utils/cbo-utils'
BrazilianUtils::CBOUtils.is_valid('2124-05')  # => true
BrazilianUtils::CBOUtils.get('212405')  # => {code: "212405", description: "Analista de desenvolvimento de sistemas"}

# CFOP
require 'brazilian-utils/cfop-utils'
BrazilianUtils::CFOPUtils.is_valid('5102')  # => true
BrazilianUtils::CFOPUtils.get('5102')[:description]  # => "Venda de mercadoria adquirida ou recebida de terceiros..."

# CNAE
require 'brazilian-utils/cnae-utils'
BrazilianUtils::CNAEUtils.is_valid('6201-5/01')  # => true
BrazilianUtils::CNAEUtils.get('6201501')
# => {code: "6201501", description: "DESENVOLVIMENTO DE PROGRAMAS DE COMPUTADOR SOB ENCOMENDA"}

# NCM
require 'brazilian-utils/ncm-utils'
BrazilianUtils::NCMUtils.is_valid('2203.00.00')  # => true
BrazilianUtils::NCMUtils.format('84713012')  # => "8471.30.12"

# CSOSN
require 'brazilian-utils/csosn-utils'
BrazilianUtils::CSOSNUtils.is_valid('101')  # => true
BrazilianUtils::CSOSNUtils.get_description('101')  # => "Tributada pelo Simples Nacional com permissão de crédito"

# CST (ICMS/IPI/PIS-COFINS)
require 'brazilian-utils/cst-utils'
BrazilianUtils::CSTUtils.is_valid('110')  # => true (ICMS)
BrazilianUtils::CSTUtils.is_valid('07', tax: 'pis')  # => true

# License Plate
require 'brazilian-utils/license-plate-utils'
BrazilianUtils::LicensePlateUtils.is_valid('ABC1234')  # => true
BrazilianUtils::LicensePlateUtils.convert_to_mercosul('ABC1234')  # => "ABC1C34"

# VIN (Chassis)
require 'brazilian-utils/vin-utils'
BrazilianUtils::VINUtils.is_valid('1HGCM82633A004352')  # => true
BrazilianUtils::VINUtils.is_valid('1M8GDM9AXKP042788')  # => true (check digit is X)

# Phone
require 'brazilian-utils/phone-utils'
BrazilianUtils::PhoneUtils.is_valid('11987654321')  # => true
BrazilianUtils::PhoneUtils.format('987654321')  # => "98765-4321"
BrazilianUtils::PhoneUtils.format('11987654321', mask: :ddd)  # => "(11) 98765-4321"

# Voter ID
require 'brazilian-utils/voter-id-utils'
BrazilianUtils::VoterIdUtils.is_valid_voter_id('690847092828')  # => true
BrazilianUtils::VoterIdUtils.format('690847092828')  # => "6908 4709 28 28"
BrazilianUtils::VoterIdUtils.generate('SP')  # => "123456780140"

# Area Code (DDD)
require 'brazilian-utils/area-code-utils'
BrazilianUtils::AreaCodeUtils.get_info('11')
# => {areaCode: 11, stateCode: "SP", stateName: "São Paulo", regionCode: "SE", regionName: "Sudeste", stateCodes: ["SP"]}
BrazilianUtils::AreaCodeUtils.list_by_state('SP')  # => [11, 12, 13, 14, 15, 16, 17, 18, 19]

# States (UF)
require 'brazilian-utils/state-utils'
BrazilianUtils::StateUtils.get_by_ibge_code('35')
# => {code: "SP", name: "São Paulo", regionCode: "SE", regionName: "Sudeste", ibgeCode: 35}
BrazilianUtils::StateUtils.get_timezone('AM')  # => "America/Manaus"

# Municipalities
require 'brazilian-utils/municipality-utils'
BrazilianUtils::MunicipalityUtils.get_by_code('3550308')  # => {code: "3550308", name: "São Paulo", stateCode: "SP"}
BrazilianUtils::MunicipalityUtils.list('DF')  # => [{code: "5300108", name: "Brasília", stateCode: "DF"}]

# NF-e/DF-e Access Key
require 'brazilian-utils/nfe-key-utils'
BrazilianUtils::NfeKeyUtils.is_valid('35170458716523000119550010000000121000123458')  # => true
BrazilianUtils::NfeKeyUtils.format('35170458716523000119550010000000121000123458')
# => "3517 0458 7165 2300 0119 5500 1000 0000 1210 0012 3458"

# Number to Words
require 'brazilian-utils/number-utils'
BrazilianUtils::NumberUtils.convert_to_words(123)  # => "cento e vinte e três"
BrazilianUtils::NumberUtils.convert_to_words(1, gender: :feminine)  # => "uma"

# Text
require 'brazilian-utils/text-utils'
BrazilianUtils::TextUtils.capitalize('fulano de tal')  # => "Fulano de Tal"
BrazilianUtils::TextUtils.remove_accents('São Paulo')  # => "Sao Paulo"
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
- [`DateUtils`](lib/brazilian-utils/date-utils.rb) - Holidays, business days, and date text
- [`EmailUtils`](lib/brazilian-utils/email-utils.rb) - Email validation
- [`LegalNatureUtils`](lib/brazilian-utils/legal-nature-utils.rb) - Legal nature codes
- [`LegalProcessUtils`](lib/brazilian-utils/legal-process-utils.rb) - Legal process IDs
- [`PISUtils`](lib/brazilian-utils/pis-utils.rb) - PIS/PASEP
- [`RENAVAMUtils`](lib/brazilian-utils/renavam-utils.rb) - Vehicle registration
- [`CNHUtils`](lib/brazilian-utils/cnh-utils.rb) - Driver's license
- [`TextUtils`](lib/brazilian-utils/text-utils.rb) - Capitalization and accent removal
- [`NumberUtils`](lib/brazilian-utils/number-utils.rb) - Numbers to words
- [`StateUtils`](lib/brazilian-utils/state-utils.rb) - Brazilian states (UF)
- [`AreaCodeUtils`](lib/brazilian-utils/area-code-utils.rb) - Area codes (DDD)
- [`BankUtils`](lib/brazilian-utils/bank-utils.rb) - Banks (COMPE/ISPB code)
- [`BankAccountUtils`](lib/brazilian-utils/bank-account-utils.rb) - Bank accounts
- [`MunicipalityUtils`](lib/brazilian-utils/municipality-utils.rb) - Municipalities (IBGE code)
- [`CFOPUtils`](lib/brazilian-utils/cfop-utils.rb) - CFOP
- [`CNAEUtils`](lib/brazilian-utils/cnae-utils.rb) - CNAE
- [`CBOUtils`](lib/brazilian-utils/cbo-utils.rb) - CBO
- [`NCMUtils`](lib/brazilian-utils/ncm-utils.rb) - NCM
- [`CSOSNUtils`](lib/brazilian-utils/csosn-utils.rb) - CSOSN
- [`CSTUtils`](lib/brazilian-utils/cst-utils.rb) - CST (ICMS/IPI/PIS-COFINS)
- [`CEIUtils`](lib/brazilian-utils/cei-utils.rb) - CEI
- [`CNOUtils`](lib/brazilian-utils/cno-utils.rb) - CNO
- [`CNSUtils`](lib/brazilian-utils/cns-utils.rb) - National Health Card
- [`CAEPFUtils`](lib/brazilian-utils/caepf-utils.rb) - CAEPF
- [`CertidaoUtils`](lib/brazilian-utils/certidao-utils.rb) - Civil registry certificate
- [`CreditCardUtils`](lib/brazilian-utils/credit-card-utils.rb) - Credit/debit card (Luhn)
- [`VINUtils`](lib/brazilian-utils/vin-utils.rb) - Chassis (VIN)
- [`PassportUtils`](lib/brazilian-utils/passport-utils.rb) - Passport
- [`IBANUtils`](lib/brazilian-utils/iban-utils.rb) - Brazilian IBAN
- [`NfeKeyUtils`](lib/brazilian-utils/nfe-key-utils.rb) - NF-e/DF-e access key
- [`PixKeyUtils`](lib/brazilian-utils/pix-key-utils.rb) - Pix key
- [`PixPayloadUtils`](lib/brazilian-utils/pix-payload-utils.rb) - Pix payload (BR Code)
- [`RegistroProfissionalUtils`](lib/brazilian-utils/registro-profissional-utils.rb) - OAB/CRM/CRO/CRP/CRC
- [`IEUtils`](lib/brazilian-utils/ie-utils.rb) - State registration (IE)
- [`BoletoUtils`](lib/brazilian-utils/boleto-utils.rb) - Bank slip (boleto)

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
- `format_currency(value)` - Format as X.XXX,XX (pass `symbol: true` for "R$ X.XXX,XX")
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
