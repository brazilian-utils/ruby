#!/usr/bin/env ruby
# frozen_string_literal: true

# Exemplo de uso do BrazilianUtils::CNPJUtils
# Este arquivo demonstra todas as funcionalidades implementadas

require_relative '../lib/brazilian-utils/cnpj-utils'

puts '=' * 80
puts 'BrazilianUtils::CNPJUtils - Exemplos de Uso'
puts '=' * 80
puts

# 1. Remover símbolos
puts '1. REMOVER SÍMBOLOS DE CNPJ'
puts '-' * 80

dirty_cnpjs = [
  '12.345/6789-01',
  '98/76.543-2101',
  '03.560.714/0001-42'
]

dirty_cnpjs.each do |cnpj|
  clean = BrazilianUtils::CNPJUtils.remove_symbols(cnpj)
  puts "Original: #{cnpj.ljust(20)} → Limpo: #{clean}"
end
puts

# 2. Formatação com display (legacy)
puts '2. FORMATAÇÃO COM DISPLAY (LEGACY)'
puts '-' * 80

cnpjs_to_display = [
  '12345678901234',
  '98765432100100',
  '00000000000000'
]

cnpjs_to_display.each do |cnpj|
  formatted = BrazilianUtils::CNPJUtils.display(cnpj)
  status = formatted ? "✓ #{formatted}" : '✗ nil (inválido)'
  puts "CNPJ: #{cnpj} → #{status}"
end
puts

# 3. Formatação com format_cnpj
puts '3. FORMATAÇÃO COM FORMAT_CNPJ'
puts '-' * 80

cnpjs_to_format = [
  { cnpj: '03560714000142', description: 'CNPJ válido' },
  { cnpj: '98765432100100', description: 'CNPJ inválido' },
  { cnpj: '11222333000181', description: 'CNPJ válido' }
]

cnpjs_to_format.each do |item|
  formatted = BrazilianUtils::CNPJUtils.format_cnpj(item[:cnpj])
  status = formatted ? "✓ #{formatted}" : '✗ nil (inválido)'
  puts "#{item[:description]}: #{item[:cnpj]}"
  puts "  Formatado: #{status}"
end
puts

# 4. Validação de CNPJ
puts '4. VALIDAÇÃO DE CNPJ'
puts '-' * 80

valid_cnpjs = [
  '03560714000142',
  '11222333000181',
  '11444777000161'
]

puts 'CNPJs Válidos:'
valid_cnpjs.each do |cnpj|
  is_valid = BrazilianUtils::CNPJUtils.valid?(cnpj)
  formatted = BrazilianUtils::CNPJUtils.format_cnpj(cnpj)
  status = is_valid ? '✓ Válido' : '✗ Inválido'
  puts "  #{formatted} - #{status}"
end
puts

invalid_cnpjs = [
  { cnpj: '00111222000133', reason: 'Dígitos verificadores incorretos' },
  { cnpj: '11222333000180', reason: 'Último dígito incorreto' },
  { cnpj: '00000000000000', reason: 'Todos os dígitos iguais' },
  { cnpj: '12345678901234', reason: 'Dígitos aleatórios' }
]

puts 'CNPJs Inválidos:'
invalid_cnpjs.each do |item|
  is_valid = BrazilianUtils::CNPJUtils.valid?(item[:cnpj])
  status = is_valid ? '✗ ERRO: Foi aceito!' : '✓ Corretamente rejeitado'
  puts "  #{item[:cnpj]} - #{item[:reason]}"
  puts "    #{status}"
end
puts

# 5. Geração de CNPJ
puts '5. GERAÇÃO DE CNPJ ALEATÓRIO'
puts '-' * 80

puts 'Gerando CNPJs com diferentes filiais:'
branches = [1, 42, 100, 1234, 9999]

branches.each do |branch|
  cnpj = BrazilianUtils::CNPJUtils.generate(branch: branch)
  formatted = BrazilianUtils::CNPJUtils.format_cnpj(cnpj)
  puts "  Filial #{branch.to_s.rjust(4, '0')}: #{formatted}"
end
puts

puts 'Gerando 5 CNPJs aleatórios com filial padrão (0001):'
5.times do |i|
  cnpj = BrazilianUtils::CNPJUtils.generate
  formatted = BrazilianUtils::CNPJUtils.format_cnpj(cnpj)
  is_valid = BrazilianUtils::CNPJUtils.valid?(cnpj)
  status = is_valid ? '✓' : '✗'
  puts "  #{i + 1}. #{formatted} #{status}"
end
puts

# 6. Workflow completo
puts '6. WORKFLOW COMPLETO: GERAR → FORMATAR → LIMPAR → VALIDAR'
puts '-' * 80

# Gerar
cnpj = BrazilianUtils::CNPJUtils.generate(branch: 42)
puts "1. Gerado: #{cnpj}"

# Formatar
formatted = BrazilianUtils::CNPJUtils.format_cnpj(cnpj)
puts "2. Formatado: #{formatted}"

# Simular recebimento de um CNPJ formatado
puts "3. Simulando recebimento de CNPJ formatado: #{formatted}"

# Limpar símbolos
cleaned = BrazilianUtils::CNPJUtils.remove_symbols(formatted)
puts "4. Limpo: #{cleaned}"

# Validar
is_valid = BrazilianUtils::CNPJUtils.valid?(cleaned)
puts "5. Válido? #{is_valid ? '✓ Sim' : '✗ Não'}"

# Verificar se é o mesmo CNPJ original
puts "6. É o mesmo CNPJ? #{cleaned == cnpj ? '✓ Sim' : '✗ Não'}"
puts

# 7. Testando CNPJs com todos os dígitos iguais
puts '7. TESTANDO CNPJs COM TODOS OS DÍGITOS IGUAIS (DEVEM SER INVÁLIDOS)'
puts '-' * 80

(0..9).each do |digit|
  cnpj = digit.to_s * 14
  is_valid = BrazilianUtils::CNPJUtils.valid?(cnpj)
  status = is_valid ? '✗ ERRO: Foi aceito!' : '✓ Corretamente rejeitado'
  puts "CNPJ #{cnpj} - #{status}"
end
puts

# 8. Casos especiais
puts '8. CASOS ESPECIAIS'
puts '-' * 80

special_cases = [
  { input: '00000000000191', description: 'CNPJ com zeros à esquerda' },
  { input: '03560714000143', description: 'CNPJ com último dígito errado' },
  { input: '03560714000141', description: 'CNPJ com penúltimo dígito errado' },
  { input: '123456789012', description: 'CNPJ com 12 dígitos (muito curto)' },
  { input: '123456789012345', description: 'CNPJ com 15 dígitos (muito longo)' }
]

special_cases.each do |item|
  is_valid = BrazilianUtils::CNPJUtils.valid?(item[:input])
  status = is_valid ? '✓ Válido' : '✗ Inválido'
  puts "#{item[:description]}:"
  puts "  CNPJ: #{item[:input]}"
  puts "  Status: #{status}"
end
puts

# 9. Comparação entre métodos (valid? vs validate, format_cnpj vs display)
puts '9. COMPARAÇÃO ENTRE MÉTODOS'
puts '-' * 80

test_cnpj = '03560714000142'
puts "CNPJ de teste: #{test_cnpj}"
puts
puts 'valid? vs validate:'
puts "  valid?(cnpj):    #{BrazilianUtils::CNPJUtils.valid?(test_cnpj)}"
puts "  validate(cnpj):  #{BrazilianUtils::CNPJUtils.validate(test_cnpj)}"
puts
puts 'format_cnpj vs display:'
puts "  format_cnpj(cnpj): #{BrazilianUtils::CNPJUtils.format_cnpj(test_cnpj)}"
puts "  display(cnpj):     #{BrazilianUtils::CNPJUtils.display(test_cnpj)}"
puts
puts 'remove_symbols vs sieve:'
formatted = BrazilianUtils::CNPJUtils.format_cnpj(test_cnpj)
puts "  remove_symbols(formatted): #{BrazilianUtils::CNPJUtils.remove_symbols(formatted)}"
puts "  sieve(formatted):          #{BrazilianUtils::CNPJUtils.sieve(formatted)}"
puts

# 10. Resumo
puts '10. RESUMO'
puts '-' * 80
puts 'A biblioteca CNPJUtils oferece:'
puts '  1. Remoção de símbolos: remove_symbols() / sieve()'
puts '  2. Formatação: format_cnpj() / display()'
puts '  3. Validação: valid?() / validate()'
puts '  4. Geração: generate(branch:)'
puts
puts 'Regras de validação:'
puts '  • Deve ter exatamente 14 dígitos'
puts '  • Não pode ser uma sequência de dígitos iguais'
puts '  • Os dois últimos dígitos são verificadores calculados'
puts
puts 'Estrutura do CNPJ: XX.XXX.XXX/FFFF-VV'
puts '  XX.XXX.XXX = Base (8 dígitos)'
puts '  FFFF       = Filial (4 dígitos)'
puts '  VV         = Verificadores (2 dígitos)'
puts

puts '=' * 80
puts 'Exemplos concluídos!'
puts '=' * 80
