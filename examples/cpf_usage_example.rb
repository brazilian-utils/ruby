#!/usr/bin/env ruby
# frozen_string_literal: true

# Exemplo de uso do BrazilianUtils::CPFUtils
# Este arquivo demonstra todas as funcionalidades implementadas

require_relative '../lib/brazilian-utils/cpf-utils'

puts '=' * 80
puts 'BrazilianUtils::CPFUtils - Exemplos de Uso'
puts '=' * 80
puts

# 1. Remover símbolos
puts '1. REMOVER SÍMBOLOS DE CPF'
puts '-' * 80

dirty_cpfs = [
  '123.456.789-01',
  '987-654-321.01',
  '821.785.374-64'
]

dirty_cpfs.each do |cpf|
  clean = BrazilianUtils::CPFUtils.remove_symbols(cpf)
  puts "Original: #{cpf.ljust(20)} → Limpo: #{clean}"
end
puts

# 2. Formatação com display (legacy)
puts '2. FORMATAÇÃO COM DISPLAY (LEGACY)'
puts '-' * 80

cpfs_to_display = [
  '12345678901',
  '98765432101',
  '00000000000'
]

cpfs_to_display.each do |cpf|
  formatted = BrazilianUtils::CPFUtils.display(cpf)
  status = formatted ? "✓ #{formatted}" : '✗ nil (inválido)'
  puts "CPF: #{cpf} → #{status}"
end
puts

# 3. Formatação com format_cpf
puts '3. FORMATAÇÃO COM FORMAT_CPF'
puts '-' * 80

cpfs_to_format = [
  { cpf: '82178537464', description: 'CPF válido' },
  { cpf: '55550207753', description: 'CPF válido' },
  { cpf: '12345678901', description: 'CPF inválido' }
]

cpfs_to_format.each do |item|
  formatted = BrazilianUtils::CPFUtils.format_cpf(item[:cpf])
  status = formatted ? "✓ #{formatted}" : '✗ nil (inválido)'
  puts "#{item[:description]}: #{item[:cpf]}"
  puts "  Formatado: #{status}"
end
puts

# 4. Validação de CPF
puts '4. VALIDAÇÃO DE CPF'
puts '-' * 80

valid_cpfs = [
  '82178537464',
  '55550207753',
  '41840660546',
  '00000000191',
  '00000000272'
]

puts 'CPFs Válidos:'
valid_cpfs.each do |cpf|
  is_valid = BrazilianUtils::CPFUtils.valid?(cpf)
  formatted = BrazilianUtils::CPFUtils.format_cpf(cpf)
  status = is_valid ? '✓ Válido' : '✗ Inválido'
  puts "  #{formatted} - #{status}"
end
puts

invalid_cpfs = [
  { cpf: '12345678901', reason: 'Dígitos verificadores incorretos' },
  { cpf: '00000000000', reason: 'Todos os dígitos iguais' },
  { cpf: '11111111111', reason: 'Todos os dígitos iguais' },
  { cpf: '82178537465', reason: 'Último dígito incorreto' },
  { cpf: '82178537454', reason: 'Penúltimo dígito incorreto' }
]

puts 'CPFs Inválidos:'
invalid_cpfs.each do |item|
  is_valid = BrazilianUtils::CPFUtils.valid?(item[:cpf])
  status = is_valid ? '✗ ERRO: Foi aceito!' : '✓ Corretamente rejeitado'
  puts "  #{item[:cpf]} - #{item[:reason]}"
  puts "    #{status}"
end
puts

# 5. Geração de CPF
puts '5. GERAÇÃO DE CPF ALEATÓRIO'
puts '-' * 80

puts 'Gerando 10 CPFs aleatórios:'
10.times do |i|
  cpf = BrazilianUtils::CPFUtils.generate
  formatted = BrazilianUtils::CPFUtils.format_cpf(cpf)
  is_valid = BrazilianUtils::CPFUtils.valid?(cpf)
  status = is_valid ? '✓' : '✗'
  puts "  #{(i + 1).to_s.rjust(2)}. #{formatted} #{status}"
end
puts

# 6. Workflow completo
puts '6. WORKFLOW COMPLETO: GERAR → FORMATAR → LIMPAR → VALIDAR'
puts '-' * 80

# Gerar
cpf = BrazilianUtils::CPFUtils.generate
puts "1. Gerado: #{cpf}"

# Formatar
formatted = BrazilianUtils::CPFUtils.format_cpf(cpf)
puts "2. Formatado: #{formatted}"

# Simular recebimento de um CPF formatado
puts "3. Simulando recebimento de CPF formatado: #{formatted}"

# Limpar símbolos
cleaned = BrazilianUtils::CPFUtils.remove_symbols(formatted)
puts "4. Limpo: #{cleaned}"

# Validar
is_valid = BrazilianUtils::CPFUtils.valid?(cleaned)
puts "5. Válido? #{is_valid ? '✓ Sim' : '✗ Não'}"

# Verificar se é o mesmo CPF original
puts "6. É o mesmo CPF? #{cleaned == cpf ? '✓ Sim' : '✗ Não'}"
puts

# 7. Testando CPFs com todos os dígitos iguais
puts '7. TESTANDO CPFs COM TODOS OS DÍGITOS IGUAIS (DEVEM SER INVÁLIDOS)'
puts '-' * 80

(0..9).each do |digit|
  cpf = digit.to_s * 11
  is_valid = BrazilianUtils::CPFUtils.valid?(cpf)
  status = is_valid ? '✗ ERRO: Foi aceito!' : '✓ Corretamente rejeitado'
  puts "CPF #{cpf} - #{status}"
end
puts

# 8. Casos especiais
puts '8. CASOS ESPECIAIS'
puts '-' * 80

special_cases = [
  { input: '00000000191', description: 'CPF com zeros à esquerda' },
  { input: '82178537465', description: 'CPF com último dígito errado' },
  { input: '82178537454', description: 'CPF com penúltimo dígito errado' },
  { input: '123456789', description: 'CPF com 9 dígitos (muito curto)' },
  { input: '123456789012', description: 'CPF com 12 dígitos (muito longo)' },
  { input: '821.785.374-64', description: 'CPF com símbolos (deve rejeitar)' }
]

special_cases.each do |item|
  is_valid = BrazilianUtils::CPFUtils.valid?(item[:input])
  status = is_valid ? '✓ Válido' : '✗ Inválido'
  puts "#{item[:description]}:"
  puts "  CPF: #{item[:input]}"
  puts "  Status: #{status}"
end
puts

# 9. Comparação entre métodos (valid? vs validate, format_cpf vs display)
puts '9. COMPARAÇÃO ENTRE MÉTODOS'
puts '-' * 80

test_cpf = '82178537464'
puts "CPF de teste: #{test_cpf}"
puts
puts 'valid? vs validate:'
puts "  valid?(cpf):    #{BrazilianUtils::CPFUtils.valid?(test_cpf)}"
puts "  validate(cpf):  #{BrazilianUtils::CPFUtils.validate(test_cpf)}"
puts
puts 'format_cpf vs display:'
puts "  format_cpf(cpf): #{BrazilianUtils::CPFUtils.format_cpf(test_cpf)}"
puts "  display(cpf):    #{BrazilianUtils::CPFUtils.display(test_cpf)}"
puts
puts 'remove_symbols vs sieve:'
formatted = BrazilianUtils::CPFUtils.format_cpf(test_cpf)
puts "  remove_symbols(formatted): #{BrazilianUtils::CPFUtils.remove_symbols(formatted)}"
puts "  sieve(formatted):          #{BrazilianUtils::CPFUtils.sieve(formatted)}"
puts

# 10. Estatísticas de geração
puts '10. ESTATÍSTICAS DE GERAÇÃO'
puts '-' * 80

puts 'Gerando 100 CPFs e verificando validade...'
cpfs = 100.times.map { BrazilianUtils::CPFUtils.generate }
valid_count = cpfs.count { |cpf| BrazilianUtils::CPFUtils.valid?(cpf) }
unique_count = cpfs.uniq.length

puts "  Total gerado: 100"
puts "  Válidos: #{valid_count} (#{valid_count}%)"
puts "  Únicos: #{unique_count} (#{unique_count}%)"
puts "  Todos válidos? #{valid_count == 100 ? '✓ Sim' : '✗ Não'}"
puts "  Nenhum começa com 0? #{cpfs.none? { |cpf| cpf[0] == '0' } ? '✓ Sim' : '✗ Não'}"
puts

# 11. Resumo
puts '11. RESUMO'
puts '-' * 80
puts 'A biblioteca CPFUtils oferece:'
puts '  1. Remoção de símbolos: remove_symbols() / sieve()'
puts '  2. Formatação: format_cpf() / display()'
puts '  3. Validação: valid?() / validate()'
puts '  4. Geração: generate()'
puts
puts 'Regras de validação:'
puts '  • Deve ter exatamente 11 dígitos'
puts '  • Não pode ser uma sequência de dígitos iguais'
puts '  • Os dois últimos dígitos são verificadores calculados'
puts '  • Deve ser apenas números (sem símbolos)'
puts
puts 'Estrutura do CPF: XXX.XXX.XXX-VV'
puts '  XXX.XXX.XXX = Base (9 dígitos)'
puts '  VV          = Verificadores (2 dígitos)'
puts

puts '=' * 80
puts 'Exemplos concluídos!'
puts '=' * 80
