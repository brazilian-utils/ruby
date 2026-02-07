# frozen_string_literal: true

# Voter ID Utils - Comprehensive Usage Examples
# ===============================================
# This file demonstrates all features of the VoterIdUtils module
# for working with Brazilian voter IDs (Título de Eleitor)

require_relative '../lib/brazilian-utils/voter-id-utils'

# For convenience, include the module
include BrazilianUtils::VoterIdUtils

puts "=" * 80
puts "BRAZILIAN VOTER ID UTILS - USAGE EXAMPLES"
puts "=" * 80

# ============================================================================
# SECTION 1: Basic Validation
# ============================================================================
puts "\n1. BASIC VALIDATION"
puts "-" * 80

voter_ids = [
  '690847092828', # Valid SP voter ID
  '163204010922', # Valid MG voter ID
  '000000000191', # Valid RJ voter ID
  '123456780140'  # Valid RS voter ID
]

puts "\nValidating voter IDs:"
voter_ids.each do |voter_id|
  result = is_valid_voter_id(voter_id)
  puts "  #{voter_id}: #{result ? '✓ VALID' : '✗ INVALID'}"
end

# Output:
# 690847092828: ✓ VALID
# 163204010922: ✓ VALID
# 000000000191: ✓ VALID
# 123456780140: ✓ VALID

# ============================================================================
# SECTION 2: Validation with Alias Methods
# ============================================================================
puts "\n2. VALIDATION WITH ALIAS METHODS"
puts "-" * 80

voter_id = '690847092828'

puts "\nDifferent ways to validate the same voter ID:"
puts "  is_valid_voter_id('#{voter_id}'): #{is_valid_voter_id(voter_id)}"
puts "  valid_voter_id?('#{voter_id}'): #{valid_voter_id?(voter_id)}"

# Both methods do the same thing
# Output:
# is_valid_voter_id('690847092828'): true
# valid_voter_id?('690847092828'): true

# ============================================================================
# SECTION 3: Invalid Formats
# ============================================================================
puts "\n3. INVALID VOTER ID FORMATS"
puts "-" * 80

invalid_voter_ids = [
  ['123', 'Too short'],
  ['12345678901234', 'Too long'],
  ['690847092A28', 'Contains letter'],
  ['690847092-28', 'Contains hyphen'],
  ['6908 4709 28 28', 'Contains spaces'],
  ['', 'Empty string']
]

puts "\nInvalid voter IDs:"
invalid_voter_ids.each do |voter_id, reason|
  result = is_valid_voter_id(voter_id)
  puts "  #{voter_id.inspect.ljust(20)} (#{reason}): #{result ? '✓ VALID' : '✗ INVALID'}"
end

# Output:
# "123"                (Too short): ✗ INVALID
# "12345678901234"     (Too long): ✗ INVALID
# "690847092A28"       (Contains letter): ✗ INVALID
# ...

# ============================================================================
# SECTION 4: Invalid Federative Union
# ============================================================================
puts "\n4. INVALID FEDERATIVE UNION"
puts "-" * 80

puts "\nVoter IDs with invalid state codes:"
puts "  12345678 00 00 (federative union = 00): #{is_valid_voter_id('123456780000') ? '✓' : '✗'}"
puts "  12345678 29 00 (federative union = 29): #{is_valid_voter_id('123456782900') ? '✓' : '✗'}"
puts "  12345678 99 00 (federative union = 99): #{is_valid_voter_id('123456789900') ? '✓' : '✗'}"

# Output:
# 12345678 00 00 (federative union = 00): ✗
# 12345678 29 00 (federative union = 29): ✗
# 12345678 99 00 (federative union = 99): ✗

# ============================================================================
# SECTION 5: Invalid Verification Digits
# ============================================================================
puts "\n5. INVALID VERIFICATION DIGITS"
puts "-" * 80

puts "\nVoter IDs with wrong verification digits:"
puts "  690847092829 (wrong second VD):"
puts "    Valid: #{is_valid_voter_id('690847092829') ? '✓' : '✗'}"

puts "  163204010921 (wrong second VD):"
puts "    Valid: #{is_valid_voter_id('163204010921') ? '✓' : '✗'}"

puts "  690847092827 (wrong second VD):"
puts "    Valid: #{is_valid_voter_id('690847092827') ? '✓' : '✗'}"

# Output:
# 690847092829 (wrong second VD):
#   Valid: ✗

# ============================================================================
# SECTION 6: Formatting Voter IDs
# ============================================================================
puts "\n6. FORMATTING VOTER IDs"
puts "-" * 80

puts "\nFormatting valid voter IDs:"
valid_ids = ['690847092828', '163204010922', '000000000191']
valid_ids.each do |voter_id|
  formatted = format_voter_id(voter_id)
  puts "  #{voter_id} → #{formatted}"
end

puts "\nFormatting invalid voter IDs returns nil:"
invalid_ids = ['123', '690847092829']
invalid_ids.each do |voter_id|
  formatted = format_voter_id(voter_id)
  puts "  #{voter_id} → #{formatted.inspect}"
end

# Output:
# 690847092828 → 6908 4709 28 28
# 163204010922 → 1632 0401 09 22
# 000000000191 → 0000 0000 01 91
# 123 → nil
# 690847092829 → nil

# ============================================================================
# SECTION 7: Format Alias Method
# ============================================================================
puts "\n7. FORMAT ALIAS METHOD"
puts "-" * 80

voter_id = '690847092828'
puts "\nDifferent ways to format:"
puts "  format_voter_id('#{voter_id}'): #{format_voter_id(voter_id)}"
puts "  format('#{voter_id}'): #{format(voter_id)}"

# Both are the same
# Output:
# format_voter_id('690847092828'): 6908 4709 28 28
# format('690847092828'): 6908 4709 28 28

# ============================================================================
# SECTION 8: Generating Voter IDs
# ============================================================================
puts "\n8. GENERATING VOTER IDs"
puts "-" * 80

puts "\nGenerate voter IDs for specific states:"
states = ['SP', 'MG', 'RJ', 'BA', 'PR']
states.each do |uf|
  voter_id = generate(uf)
  formatted = format(voter_id)
  state_code = voter_id[8..9]
  puts "  #{uf} (#{state_code}): #{formatted}"
end

# Output (random, will vary):
# SP (01): 1234 5678 01 40
# MG (02): 9876 5432 02 11
# RJ (03): 5555 5555 03 91
# ...

# ============================================================================
# SECTION 9: Generate with Default (Foreigners)
# ============================================================================
puts "\n9. GENERATE FOR FOREIGNERS (ZZ)"
puts "-" * 80

puts "\nGenerate voter ID for foreigners (default ZZ = 28):"
3.times do |i|
  voter_id = generate # Default is 'ZZ'
  formatted = format(voter_id)
  puts "  #{i + 1}. #{formatted} (state code: #{voter_id[8..9]})"
end

# Output (random):
# 1. 5555 5555 28 01 (state code: 28)
# 2. 1234 5678 28 45 (state code: 28)
# 3. 9876 5432 28 89 (state code: 28)

# ============================================================================
# SECTION 10: Case Insensitive UF Codes
# ============================================================================
puts "\n10. CASE INSENSITIVE UF CODES"
puts "-" * 80

puts "\nGenerate with different case variations:"
['SP', 'sp', 'Sp', 'sP'].each do |uf|
  voter_id = generate(uf)
  state_code = voter_id[8..9]
  puts "  generate('#{uf}'): state code = #{state_code}"
end

# Output:
# generate('SP'): state code = 01
# generate('sp'): state code = 01
# generate('Sp'): state code = 01
# generate('sP'): state code = 01

# ============================================================================
# SECTION 11: Invalid UF Codes Return nil
# ============================================================================
puts "\n11. INVALID UF CODES"
puts "-" * 80

puts "\nGenerating with invalid UF codes returns nil:"
invalid_ufs = ['XX', 'AB', '123', '']
invalid_ufs.each do |uf|
  result = generate(uf)
  puts "  generate('#{uf}'): #{result.inspect}"
end

# Output:
# generate('XX'): nil
# generate('AB'): nil
# generate('123'): nil
# generate(''): nil

# ============================================================================
# SECTION 12: All Brazilian States
# ============================================================================
puts "\n12. GENERATE FOR ALL UF CODES"
puts "-" * 80

puts "\nGenerate voter IDs for all Brazilian states and territories:"
all_ufs = %w[SP MG RJ RS BA PR CE PE SC GO MA PB PA ES PI RN AL MT MS DF SE AM RO AC AP RR TO ZZ]
all_ufs.each do |uf|
  voter_id = generate(uf)
  uf_code = UF_CODES[uf]
  puts "  #{uf.ljust(2)} (#{uf_code}): #{format(voter_id)}"
end

# Output (random):
# SP (01): 1234 5678 01 40
# MG (02): 9876 5432 02 11
# RJ (03): 5555 5555 03 91
# ...
# ZZ (28): 1111 2222 28 56

# ============================================================================
# SECTION 13: Batch Validation
# ============================================================================
puts "\n13. BATCH VALIDATION"
puts "-" * 80

voter_ids_batch = [
  '690847092828',
  '163204010922',
  '000000000191',
  '123456789012',
  '690847092A28',
  '123',
  ''
]

valid_count = 0
invalid_count = 0

puts "\nValidating batch of voter IDs:"
voter_ids_batch.each do |voter_id|
  if is_valid_voter_id(voter_id)
    puts "  ✓ #{format_voter_id(voter_id)}"
    valid_count += 1
  else
    puts "  ✗ #{voter_id.inspect} [INVALID]"
    invalid_count += 1
  end
end

puts "\nSummary:"
puts "  Total: #{voter_ids_batch.length}"
puts "  Valid: #{valid_count}"
puts "  Invalid: #{invalid_count}"
puts "  Success rate: #{(valid_count.to_f / voter_ids_batch.length * 100).round(2)}%"

# Output:
# ✓ 6908 4709 28 28
# ✓ 1632 0401 09 22
# ✓ 0000 0000 01 91
# ✗ "123456789012" [INVALID]
# ...

# ============================================================================
# SECTION 14: Voter Registration Form Validation
# ============================================================================
puts "\n14. VOTER REGISTRATION FORM VALIDATION"
puts "-" * 80

def validate_voter_registration(voter_id, name)
  puts "\nValidating registration for #{name}:"
  puts "  Voter ID: #{voter_id}"
  
  if voter_id.nil? || voter_id.empty?
    puts "  Status: ✗ REJECTED - Voter ID is required"
    return false
  end
  
  unless is_valid_voter_id(voter_id)
    puts "  Status: ✗ REJECTED - Invalid voter ID"
    return false
  end
  
  formatted = format_voter_id(voter_id)
  state_code = voter_id[8..9]
  puts "  Formatted: #{formatted}"
  puts "  State code: #{state_code}"
  puts "  Status: ✓ APPROVED"
  true
end

# Test with different inputs
validate_voter_registration('690847092828', 'João Silva')
validate_voter_registration('123456789012', 'Maria Santos')
validate_voter_registration('', 'Pedro Costa')
validate_voter_registration('163204010922', 'Ana Oliveira')

# Output:
# Validating registration for João Silva:
#   Voter ID: 690847092828
#   Formatted: 6908 4709 28 28
#   State code: 28
#   Status: ✓ APPROVED
# ...

# ============================================================================
# SECTION 15: Database Cleanup
# ============================================================================
puts "\n15. DATABASE CLEANUP SIMULATION"
puts "-" * 80

# Simulate database with voter records
database = [
  { id: 1, name: 'João Silva', voter_id: '690847092828' },
  { id: 2, name: 'Maria Santos', voter_id: '123456789012' },
  { id: 3, name: 'Pedro Costa', voter_id: '163204010922' },
  { id: 4, name: 'Ana Oliveira', voter_id: '000000000191' },
  { id: 5, name: 'Carlos Souza', voter_id: '690847092A28' }
]

puts "\nCleaning invalid voter IDs from database:"
valid_records = []
invalid_records = []

database.each do |record|
  if is_valid_voter_id(record[:voter_id])
    valid_records << record
    puts "  ✓ Record ##{record[:id]}: #{record[:name]} - #{format_voter_id(record[:voter_id])}"
  else
    invalid_records << record
    puts "  ✗ Record ##{record[:id]}: #{record[:name]} - #{record[:voter_id].inspect} [INVALID]"
  end
end

puts "\nCleanup Summary:"
puts "  Total records: #{database.length}"
puts "  Valid records: #{valid_records.length}"
puts "  Invalid records: #{invalid_records.length}"
puts "  Records to remove: #{invalid_records.map { |r| "##{r[:id]}" }.join(', ')}"

# Output:
# ✓ Record #1: João Silva - 6908 4709 28 28
# ✗ Record #2: Maria Santos - "123456789012" [INVALID]
# ...

# ============================================================================
# SECTION 16: Import Validation
# ============================================================================
puts "\n16. IMPORT VALIDATION"
puts "-" * 80

# Simulate CSV import
import_data = [
  { line: 1, data: 'João Silva,690847092828' },
  { line: 2, data: 'Maria Santos,163204010922' },
  { line: 3, data: 'Pedro Costa,123' },
  { line: 4, data: 'Ana Oliveira,000000000191' },
  { line: 5, data: 'Carlos Souza,690847092A28' }
]

puts "\nValidating imported voter IDs:"
errors = []

import_data.each do |row|
  name, voter_id = row[:data].split(',')
  
  if is_valid_voter_id(voter_id)
    puts "  ✓ Line #{row[:line]}: #{name.ljust(20)} #{format_voter_id(voter_id)}"
  else
    puts "  ✗ Line #{row[:line]}: #{name.ljust(20)} #{voter_id.inspect} [INVALID]"
    errors << { line: row[:line], name: name, voter_id: voter_id }
  end
end

if errors.empty?
  puts "\n✓ Import completed successfully - all voter IDs are valid"
else
  puts "\n✗ Import completed with errors:"
  errors.each do |error|
    puts "    Line #{error[:line]}: #{error[:name]} has invalid voter ID '#{error[:voter_id]}'"
  end
end

# Output:
# ✓ Line 1: João Silva          6908 4709 28 28
# ✓ Line 2: Maria Santos        1632 0401 09 22
# ✗ Line 3: Pedro Costa         "123" [INVALID]
# ...

# ============================================================================
# SECTION 17: Statistics Generation
# ============================================================================
puts "\n17. VOTER ID STATISTICS"
puts "-" * 80

# Generate sample data
sample_size = 100
puts "\nGenerating #{sample_size} random voter IDs..."

state_distribution = Hash.new(0)
all_ufs = %w[SP MG RJ RS BA PR CE PE SC GO]

sample_size.times do
  uf = all_ufs.sample
  voter_id = generate(uf)
  state_distribution[uf] += 1
end

puts "\nState Distribution:"
state_distribution.sort_by { |_uf, count| -count }.each do |uf, count|
  percentage = (count.to_f / sample_size * 100).round(2)
  bar = '█' * (count / 2)
  puts "  #{uf}: #{count.to_s.rjust(3)} (#{percentage.to_s.rjust(6)}%) #{bar}"
end

# Output (random):
# SP:  15 ( 15.00%) ███████
# MG:  12 ( 12.00%) ██████
# RJ:  11 ( 11.00%) █████
# ...

# ============================================================================
# SECTION 18: Edge Cases and Special Scenarios
# ============================================================================
puts "\n18. EDGE CASES AND SPECIAL SCENARIOS"
puts "-" * 80

puts "\nTesting edge cases:"

# All zeros (except verification digits)
test_cases = [
  ['000000000191', 'Valid voter ID with zeros'],
  ['548044090191', 'Voter ID with VD = 0 (rest = 10)'],
  ['1234567890101', '13-digit voter ID (SP/MG edge case)']
]

test_cases.each do |voter_id, description|
  result = is_valid_voter_id(voter_id)
  status = result ? '✓ VALID' : '✗ INVALID'
  formatted = result ? format_voter_id(voter_id) : 'N/A'
  puts "  #{description}:"
  puts "    Input: #{voter_id}"
  puts "    Status: #{status}"
  puts "    Formatted: #{formatted}" if result
  puts
end

# Output:
# Valid voter ID with zeros:
#   Input: 000000000191
#   Status: ✓ VALID
#   Formatted: 0000 0000 01 91
# ...

# ============================================================================
# SECTION 19: UF Code Reference Table
# ============================================================================
puts "\n19. UF CODE REFERENCE TABLE"
puts "-" * 80

puts "\nComplete UF code mapping:"
puts "  UF  | Code | State Name"
puts "  ----|------|" + ("-" * 30)

uf_names = {
  'SP' => 'São Paulo', 'MG' => 'Minas Gerais', 'RJ' => 'Rio de Janeiro',
  'RS' => 'Rio Grande do Sul', 'BA' => 'Bahia', 'PR' => 'Paraná',
  'CE' => 'Ceará', 'PE' => 'Pernambuco', 'SC' => 'Santa Catarina',
  'GO' => 'Goiás', 'MA' => 'Maranhão', 'PB' => 'Paraíba',
  'PA' => 'Pará', 'ES' => 'Espírito Santo', 'PI' => 'Piauí',
  'RN' => 'Rio Grande do Norte', 'AL' => 'Alagoas', 'MT' => 'Mato Grosso',
  'MS' => 'Mato Grosso do Sul', 'DF' => 'Distrito Federal', 'SE' => 'Sergipe',
  'AM' => 'Amazonas', 'RO' => 'Rondônia', 'AC' => 'Acre',
  'AP' => 'Amapá', 'RR' => 'Roraima', 'TO' => 'Tocantins',
  'ZZ' => 'Foreigner / Estrangeiro'
}

UF_CODES.sort_by { |_uf, code| code }.each do |uf, code|
  puts "  #{uf.ljust(4)}| #{code.ljust(5)}| #{uf_names[uf]}"
end

# Output:
# UF  | Code | State Name
# ----|------|------------------------------
# SP  | 01   | São Paulo
# MG  | 02   | Minas Gerais
# RJ  | 03   | Rio de Janeiro
# ...

# ============================================================================
# SECTION 20: Real-World Valid Examples
# ============================================================================
puts "\n20. REAL-WORLD VALID VOTER ID EXAMPLES"
puts "-" * 80

puts "\nKnown valid voter IDs with formatting:"
known_valid = [
  '690847092828',
  '163204010922',
  '000000000191',
  '123456780140',
  '548044090191'
]

known_valid.each_with_index do |voter_id, index|
  formatted = format_voter_id(voter_id)
  state_code = voter_id[8..9]
  vd1 = voter_id[10]
  vd2 = voter_id[11]
  
  puts "\n  Example #{index + 1}:"
  puts "    Raw:       #{voter_id}"
  puts "    Formatted: #{formatted}"
  puts "    State:     #{state_code}"
  puts "    VD1:       #{vd1}"
  puts "    VD2:       #{vd2}"
  puts "    Valid:     #{is_valid_voter_id(voter_id) ? '✓ Yes' : '✗ No'}"
end

# Output:
# Example 1:
#   Raw:       690847092828
#   Formatted: 6908 4709 28 28
#   State:     28
#   VD1:       2
#   VD2:       8
#   Valid:     ✓ Yes

puts "\n" + "=" * 80
puts "END OF EXAMPLES"
puts "=" * 80
