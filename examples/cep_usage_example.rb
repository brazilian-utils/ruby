#!/usr/bin/env ruby
# frozen_string_literal: true

# Exemplo de uso do BrazilianUtils::CEPUtils
# Este arquivo demonstra todas as funcionalidades implementadas

require_relative 'lib/brazilian-utils/cep-utils'

puts '=' * 80
puts 'BrazilianUtils::CEPUtils - Exemplos de Uso'
puts '=' * 80
puts

# 1. Formatação de CEP
puts '1. FORMATAÇÃO DE CEP'
puts '-' * 80

cep_raw = '01310100'
cep_formatted = BrazilianUtils::CEPUtils.format_cep(cep_raw)
puts "CEP bruto: #{cep_raw}"
puts "CEP formatado: #{cep_formatted}"
puts

# 2. Validação de CEP
puts '2. VALIDAÇÃO DE CEP'
puts '-' * 80

test_ceps = ['01310100', '12345', 'abcdefgh', '12345-678']
test_ceps.each do |cep|
  is_valid = BrazilianUtils::CEPUtils.valid?(cep)
  puts "CEP '#{cep}' é válido? #{is_valid}"
end
puts

# 3. Remover símbolos
puts '3. REMOVER SÍMBOLOS'
puts '-' * 80

dirty_cep = '01310-100'
clean_cep = BrazilianUtils::CEPUtils.remove_symbols(dirty_cep)
puts "CEP com símbolos: #{dirty_cep}"
puts "CEP limpo: #{clean_cep}"
puts

# 4. Gerar CEP aleatório
puts '4. GERAR CEP ALEATÓRIO'
puts '-' * 80

5.times do |i|
  random_cep = BrazilianUtils::CEPUtils.generate
  formatted_random = BrazilianUtils::CEPUtils.format_cep(random_cep)
  puts "#{i + 1}. CEP aleatório: #{formatted_random}"
end
puts

# 5. Validação de UF
puts '5. VALIDAÇÃO E INFORMAÇÕES DE UF (ESTADO)'
puts '-' * 80

puts "UF 'SP' é válida? #{BrazilianUtils::UF.valid?('SP')}"
puts "UF 'XX' é válida? #{BrazilianUtils::UF.valid?('XX')}"
puts "Nome do estado 'SP': #{BrazilianUtils::UF.name_from_code('SP')}"
puts "Código do estado 'Rio de Janeiro': #{BrazilianUtils::UF.code_from_name('Rio de Janeiro')}"
puts

# 6. Buscar endereço por CEP (requer conexão com internet)
puts '6. BUSCAR ENDEREÇO POR CEP (Requer Internet)'
puts '-' * 80

test_cep = '01310100' # Avenida Paulista, São Paulo
puts "Buscando endereço para CEP: #{test_cep}..."

begin
  address = BrazilianUtils::CEPUtils.get_address_from_cep(test_cep)
  
  if address
    puts "✓ Endereço encontrado!"
    puts "  CEP: #{address.cep}"
    puts "  Logradouro: #{address.logradouro}"
    puts "  Bairro: #{address.bairro}"
    puts "  Cidade: #{address.localidade}"
    puts "  UF: #{address.uf}"
    puts "  IBGE: #{address.ibge}"
    puts "  DDD: #{address.ddd}"
  else
    puts "✗ Endereço não encontrado ou API indisponível"
  end
rescue StandardError => e
  puts "✗ Erro ao buscar endereço: #{e.message}"
  puts "  (Isso é normal se não houver conexão com a internet)"
end
puts

# 7. Buscar CEPs por endereço (requer conexão com internet)
puts '7. BUSCAR CEPs POR ENDEREÇO (Requer Internet)'
puts '-' * 80

puts "Buscando CEPs para: SP / São Paulo / Paulista..."

begin
  addresses = BrazilianUtils::CEPUtils.get_cep_information_from_address('SP', 'São Paulo', 'Paulista')
  
  if addresses && addresses.any?
    puts "✓ Encontrados #{addresses.length} resultados:"
    addresses.first(5).each_with_index do |addr, idx|
      puts "  #{idx + 1}. #{addr.cep} - #{addr.logradouro}, #{addr.bairro}"
    end
    puts "  ... (mostrando apenas os primeiros 5 resultados)" if addresses.length > 5
  else
    puts "✗ Nenhum resultado encontrado ou API indisponível"
  end
rescue StandardError => e
  puts "✗ Erro ao buscar CEPs: #{e.message}"
  puts "  (Isso é normal se não houver conexão com a internet)"
end
puts

# 8. Tratamento de exceções
puts '8. TRATAMENTO DE EXCEÇÕES'
puts '-' * 80

puts "Testando CEP inválido com raise_exceptions: true"
begin
  BrazilianUtils::CEPUtils.get_address_from_cep('invalid', raise_exceptions: true)
rescue BrazilianUtils::InvalidCEP => e
  puts "✓ Exceção capturada: #{e.class} - #{e.message}"
end

puts "\nTestando UF inválida com raise_exceptions: true"
begin
  BrazilianUtils::CEPUtils.get_cep_information_from_address('XX', 'City', 'Street', raise_exceptions: true)
rescue ArgumentError => e
  puts "✓ Exceção capturada: #{e.class} - #{e.message}"
end
puts

# 9. Listando todos os estados brasileiros
puts '9. TODOS OS ESTADOS BRASILEIROS'
puts '-' * 80

BrazilianUtils::UF::STATES.each do |code, name|
  puts "#{code} - #{name}"
end
puts

puts '=' * 80
puts 'Exemplos concluídos!'
puts '=' * 80
