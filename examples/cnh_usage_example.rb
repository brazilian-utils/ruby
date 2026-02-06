#!/usr/bin/env ruby
# frozen_string_literal: true

# Exemplo de uso do BrazilianUtils::CNHUtils
# Este arquivo demonstra todas as funcionalidades implementadas

require_relative '../lib/brazilian-utils/cnh-utils'

puts '=' * 80
puts 'BrazilianUtils::CNHUtils - Exemplos de Uso'
puts '=' * 80
puts

# 1. Validação de CNH válida
puts '1. VALIDAÇÃO DE CNH VÁLIDA'
puts '-' * 80

valid_cnhs = [
  '98765432100',
  '987654321-00',
  '987.654.321-00',
  '987 654 321 00'
]

valid_cnhs.each do |cnh|
  is_valid = BrazilianUtils::CNHUtils.valid?(cnh)
  puts "CNH '#{cnh}' é válida? #{is_valid ? '✓ Sim' : '✗ Não'}"
end
puts

# 2. Validação de CNH inválida
puts '2. VALIDAÇÃO DE CNH INVÁLIDA'
puts '-' * 80

invalid_cnhs = [
  { cnh: '12345678901', reason: 'Dígitos verificadores incorretos' },
  { cnh: 'A2C45678901', reason: 'Contém letras' },
  { cnh: '00000000000', reason: 'Todos os dígitos iguais' },
  { cnh: '11111111111', reason: 'Todos os dígitos iguais' },
  { cnh: '123456789', reason: 'Menos de 11 dígitos' },
  { cnh: '123456789012', reason: 'Mais de 11 dígitos' },
  { cnh: '', reason: 'String vazia' },
  { cnh: '98765432199', reason: 'Segundo dígito verificador incorreto' },
  { cnh: '98765432190', reason: 'Primeiro dígito verificador incorreto' }
]

invalid_cnhs.each do |item|
  is_valid = BrazilianUtils::CNHUtils.valid?(item[:cnh])
  status = is_valid ? '✗ Inesperadamente válida' : '✓ Corretamente inválida'
  puts "CNH '#{item[:cnh]}' - #{item[:reason]}"
  puts "  Resultado: #{status}"
end
puts

# 3. Testando com diferentes formatos
puts '3. TESTANDO DIFERENTES FORMATOS DE ENTRADA'
puts '-' * 80

test_formats = [
  { input: '98765432100', description: 'Apenas números' },
  { input: '987-654-321-00', description: 'Com hífens' },
  { input: '987.654.321-00', description: 'Com pontos e hífen' },
  { input: '987 654 321 00', description: 'Com espaços' },
  { input: '987/654/321-00', description: 'Com barras e hífen' },
  { input: 98765432100, description: 'Como número inteiro' }
]

test_formats.each do |format|
  is_valid = BrazilianUtils::CNHUtils.valid?(format[:input])
  puts "Formato: #{format[:description]}"
  puts "  Entrada: #{format[:input]}"
  puts "  Válido? #{is_valid ? '✓ Sim' : '✗ Não'}"
end
puts

# 4. Testando sequências de dígitos iguais
puts '4. TESTANDO SEQUÊNCIAS DE DÍGITOS IGUAIS (DEVEM SER INVÁLIDAS)'
puts '-' * 80

(0..9).each do |digit|
  cnh = digit.to_s * 11
  is_valid = BrazilianUtils::CNHUtils.valid?(cnh)
  status = is_valid ? '✗ ERRO: Foi aceita!' : '✓ Corretamente rejeitada'
  puts "CNH '#{cnh}' - #{status}"
end
puts

# 5. Casos especiais
puts '5. CASOS ESPECIAIS'
puts '-' * 80

special_cases = [
  { input: nil, description: 'nil' },
  { input: '', description: 'String vazia' },
  { input: '---...', description: 'Apenas símbolos' },
  { input: 'ABCDEFGHIJK', description: 'Apenas letras' },
  { input: 'ABC12345678', description: 'Letras e números misturados' }
]

special_cases.each do |special|
  is_valid = BrazilianUtils::CNHUtils.valid?(special[:input])
  puts "#{special[:description]}: #{special[:input].inspect}"
  puts "  Válido? #{is_valid ? '✗ Inesperadamente válido' : '✓ Corretamente inválido'}"
end
puts

# 6. Resumo
puts '6. RESUMO'
puts '-' * 80
puts 'A biblioteca CNHUtils valida CNHs brasileiras seguindo as regras:'
puts '  1. Deve ter exatamente 11 dígitos (após remover símbolos)'
puts '  2. Não pode ser uma sequência de dígitos iguais'
puts '  3. Os dois últimos dígitos são verificadores calculados'
puts '  4. Símbolos e espaços são automaticamente ignorados'
puts '  5. Suporta apenas CNHs criadas a partir de 2022'
puts

puts '=' * 80
puts 'Exemplos concluídos!'
puts '=' * 80
