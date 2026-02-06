#!/usr/bin/env ruby
# frozen_string_literal: true

# Exemplo de uso do BrazilianUtils::CurrencyUtils
# Este arquivo demonstra todas as funcionalidades implementadas

require_relative '../lib/brazilian-utils/currency-utils'

puts '=' * 80
puts 'BrazilianUtils::CurrencyUtils - Exemplos de Uso'
puts '=' * 80
puts

# 1. Formatação de moeda
puts '1. FORMATAÇÃO DE MOEDA (format_currency)'
puts '-' * 80

values_to_format = [
  1234.56,
  0,
  -9876.54,
  1000,
  0.50,
  1234567.89,
  1234567890.12,
  '2500.75',
  10.5
]

values_to_format.each do |value|
  formatted = BrazilianUtils::CurrencyUtils.format_currency(value)
  puts "#{value.to_s.rjust(15)} → #{formatted}"
end
puts

# 2. Valores inválidos na formatação
puts '2. VALORES INVÁLIDOS NA FORMATAÇÃO'
puts '-' * 80

invalid_values = ['invalid', nil, 'abc']

invalid_values.each do |value|
  formatted = BrazilianUtils::CurrencyUtils.format_currency(value)
  puts "#{value.inspect.rjust(15)} → #{formatted.inspect}"
end
puts

# 3. Conversão para texto - Valores simples
puts '3. CONVERSÃO PARA TEXTO - VALORES SIMPLES'
puts '-' * 80

simple_values = [
  { value: 0.00, description: 'Zero' },
  { value: 1.00, description: 'Um real' },
  { value: 2.00, description: 'Dois reais' },
  { value: 10.00, description: 'Dez reais' },
  { value: 100.00, description: 'Cem reais' },
  { value: 1000.00, description: 'Mil reais' }
]

simple_values.each do |item|
  text = BrazilianUtils::CurrencyUtils.convert_real_to_text(item[:value])
  puts "R$ #{format('%10.2f', item[:value])} → #{text}"
end
puts

# 4. Conversão para texto - Apenas centavos
puts '4. CONVERSÃO PARA TEXTO - APENAS CENTAVOS'
puts '-' * 80

centavos_values = [0.01, 0.50, 0.99, 0.25, 0.75]

centavos_values.each do |value|
  text = BrazilianUtils::CurrencyUtils.convert_real_to_text(value)
  formatted = BrazilianUtils::CurrencyUtils.format_currency(value)
  puts "#{formatted.rjust(12)} → #{text}"
end
puts

# 5. Conversão para texto - Reais e centavos
puts '5. CONVERSÃO PARA TEXTO - REAIS E CENTAVOS'
puts '-' * 80

mixed_values = [1.50, 2.01, 10.99, 1523.45, 100.50]

mixed_values.each do |value|
  text = BrazilianUtils::CurrencyUtils.convert_real_to_text(value)
  formatted = BrazilianUtils::CurrencyUtils.format_currency(value)
  puts "#{formatted}"
  puts "  → #{text}"
  puts
end

# 6. Conversão para texto - Valores grandes
puts '6. CONVERSÃO PARA TEXTO - VALORES GRANDES'
puts '-' * 80

large_values = [
  { value: 1_000_000.00, description: '1 Milhão' },
  { value: 2_000_000.00, description: '2 Milhões' },
  { value: 1_000_000_000.00, description: '1 Bilhão' },
  { value: 1_234_567.89, description: '1.2 Milhões com centavos' }
]

large_values.each do |item|
  text = BrazilianUtils::CurrencyUtils.convert_real_to_text(item[:value])
  formatted = BrazilianUtils::CurrencyUtils.format_currency(item[:value])
  puts "#{item[:description]}:"
  puts "  Numérico: #{formatted}"
  puts "  Extenso:  #{text}"
  puts
end

# 7. Valores negativos
puts '7. VALORES NEGATIVOS'
puts '-' * 80

negative_values = [-10.50, -0.50, -1000.00, -1523.45]

negative_values.each do |value|
  text = BrazilianUtils::CurrencyUtils.convert_real_to_text(value)
  formatted = BrazilianUtils::CurrencyUtils.format_currency(value)
  puts "#{formatted}"
  puts "  → #{text}"
  puts
end

# 8. Arredondamento (round down)
puts '8. ARREDONDAMENTO (VALORES TRUNCADOS PARA 2 CASAS)'
puts '-' * 80

rounding_values = [
  { value: 1.999, expected_text: '1.99' },
  { value: 0.555, expected_text: '0.55' },
  { value: 10.12345, expected_text: '10.12' }
]

rounding_values.each do |item|
  text = BrazilianUtils::CurrencyUtils.convert_real_to_text(item[:value])
  formatted = BrazilianUtils::CurrencyUtils.format_currency(item[:value])
  puts "Valor original: #{item[:value]}"
  puts "  Formatado: #{formatted}"
  puts "  Extenso:   #{text}"
  puts
end

# 9. Casos especiais de números
puts '9. CASOS ESPECIAIS DE NÚMEROS'
puts '-' * 80

special_numbers = [11.00, 15.00, 20.00, 21.00, 101.00, 200.00, 1000.00]

special_numbers.each do |value|
  text = BrazilianUtils::CurrencyUtils.convert_real_to_text(value)
  formatted = BrazilianUtils::CurrencyUtils.format_currency(value)
  puts "#{formatted.rjust(15)} → #{text}"
end
puts

# 10. Workflow completo: Emissão de cheque
puts '10. WORKFLOW COMPLETO: EMISSÃO DE CHEQUE'
puts '-' * 80

cheque_value = 1523.45

puts 'Dados do Cheque:'
puts '-' * 40
formatted = BrazilianUtils::CurrencyUtils.format_currency(cheque_value)
text = BrazilianUtils::CurrencyUtils.convert_real_to_text(cheque_value)

puts "Valor numérico: #{formatted}"
puts "Valor por extenso:"
puts "  #{text}"
puts

# 11. Workflow completo: Nota fiscal
puts '11. WORKFLOW COMPLETO: NOTA FISCAL'
puts '-' * 80

items = [
  { name: 'Produto A', price: 150.00 },
  { name: 'Produto B', price: 75.50 },
  { name: 'Produto C', price: 1200.00 }
]

puts 'NOTA FISCAL'
puts '-' * 40
total = 0

items.each do |item|
  formatted = BrazilianUtils::CurrencyUtils.format_currency(item[:price])
  puts "#{item[:name].ljust(12)} #{formatted.rjust(15)}"
  total += item[:price]
end

puts '-' * 40
total_formatted = BrazilianUtils::CurrencyUtils.format_currency(total)
total_text = BrazilianUtils::CurrencyUtils.convert_real_to_text(total)
puts "#{'TOTAL'.ljust(12)} #{total_formatted.rjust(15)}"
puts
puts 'Valor por extenso:'
puts "  #{total_text}"
puts

# 12. Testes com diferentes tipos de entrada
puts '12. DIFERENTES TIPOS DE ENTRADA'
puts '-' * 80

different_inputs = [
  { input: 100, type: 'Integer' },
  { input: 100.50, type: 'Float' },
  { input: '100.50', type: 'String' },
  { input: BigDecimal('100.50'), type: 'BigDecimal' }
]

different_inputs.each do |item|
  formatted = BrazilianUtils::CurrencyUtils.format_currency(item[:input])
  text = BrazilianUtils::CurrencyUtils.convert_real_to_text(item[:input])
  puts "Tipo: #{item[:type].ljust(12)} Input: #{item[:input].inspect}"
  puts "  Formatado: #{formatted}"
  puts "  Extenso:   #{text}"
  puts
end

# 13. Valores inválidos na conversão
puts '13. VALORES INVÁLIDOS NA CONVERSÃO PARA TEXTO'
puts '-' * 80

invalid_for_text = [
  { value: 'invalid', description: 'String inválida' },
  { value: nil, description: 'Nil' },
  { value: 1_000_000_000_000_001.00, description: 'Acima do limite (1 quadrilhão)' }
]

invalid_for_text.each do |item|
  text = BrazilianUtils::CurrencyUtils.convert_real_to_text(item[:value])
  puts "#{item[:description]}: #{item[:value].inspect}"
  puts "  Resultado: #{text.inspect}"
end
puts

# 14. Resumo
puts '14. RESUMO'
puts '-' * 80
puts 'A biblioteca CurrencyUtils oferece:'
puts '  1. format_currency(value): Formata valores em moeda brasileira (R$)'
puts '  2. convert_real_to_text(amount): Converte valores para extenso em português'
puts
puts 'Características da formatação:'
puts '  • Separador de milhares: . (ponto)'
puts '  • Separador decimal: , (vírgula)'
puts '  • Sempre 2 casas decimais'
puts '  • Suporta valores negativos'
puts '  • Suporta números muito grandes'
puts
puts 'Características da conversão para texto:'
puts '  • Valores arredondados para baixo (truncados) em 2 casas decimais'
puts '  • Máximo: 1 quadrilhão de reais'
puts '  • Português gramaticalmente correto (singular/plural)'
puts '  • Conectores adequados para milhões/bilhões'
puts '  • Valores negativos com prefixo "Menos"'
puts

puts '=' * 80
puts 'Exemplos concluídos!'
puts '=' * 80
