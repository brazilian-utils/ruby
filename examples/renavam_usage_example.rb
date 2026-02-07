require 'brazilian-utils/renavam-utils'

include BrazilianUtils::RENAVAMUtils

puts "=" * 80
puts "Brazilian RENAVAM Utils - Usage Examples"
puts "=" * 80

# ============================================================================
# Section 1: Validating Valid RENAVAM Numbers
# ============================================================================
puts "\n1. Validating Valid RENAVAM Numbers"
puts "-" * 80

valid_renavams = [
  '86769597308'
]

# Calculate a few valid RENAVAMs to demonstrate
test_bases = ['1234567890', '9876543210', '5555555550', '0123456789', '8676959730']
test_bases.each do |base|
  dv = send(:calculate_renavam_dv, base + '0')
  valid_renavams << (base + dv.to_s)
end

valid_renavams.each do |renavam|
  valid = is_valid_renavam(renavam)
  status = valid ? '✓ VALID' : '✗ INVALID'
  puts "  #{renavam.ljust(15)} → #{status}"
end

# ============================================================================
# Section 2: Validating Invalid RENAVAM Numbers
# ============================================================================
puts "\n2. Validating Invalid RENAVAM Numbers"
puts "-" * 80

invalid_renavams = [
  '12345678901',      # Wrong checksum
  '1234567890a',      # Contains letter
  '12345678 901',     # Contains space
  '12345678',         # Too short
  '123456789012',     # Too long
  '00000000000',      # All zeros
  '11111111111',      # All ones
  '99999999999',      # All nines
  '',                 # Empty
  '12345-678901',     # Contains hyphen
  '123.456.789.01'    # Contains dots
]

invalid_renavams.each do |renavam|
  valid = is_valid_renavam(renavam)
  status = valid ? '✓ VALID' : '✗ INVALID'
  puts "  #{renavam.ljust(20)} → #{status}"
end

# ============================================================================
# Section 3: Using the is_valid Alias
# ============================================================================
puts "\n3. Using the is_valid Alias"
puts "-" * 80

test_renavams = ['86769597308', '12345678901', '11111111111']

test_renavams.each do |renavam|
  if is_valid(renavam)
    puts "  ✓ #{renavam} is valid"
  else
    puts "  ✗ #{renavam} is invalid"
  end
end

# ============================================================================
# Section 4: Using the valid? Alias
# ============================================================================
puts "\n4. Using the valid? Alias"
puts "-" * 80

test_renavams.each do |renavam|
  result = valid?(renavam)
  puts "  valid?('#{renavam}') → #{result}"
end

# ============================================================================
# Section 5: Understanding the Verification Digit Calculation
# ============================================================================
puts "\n5. Understanding the Verification Digit Calculation"
puts "-" * 80

puts "  Example: RENAVAM 86769597308"
puts

renavam = '86769597308'
base = renavam[0..9]
expected_dv = renavam[10].to_i

puts "  Full RENAVAM: #{renavam}"
puts "  Base (first 10 digits): #{base}"
puts "  Verification digit (11th digit): #{expected_dv}"
puts
puts "  Calculation steps:"
puts "    1. Base digits:     #{base.chars.join(' ')}"
puts "    2. Reversed:        #{base.reverse.chars.join(' ')}"
puts "    3. Weights:         2 3 4 5 6 7 8 9 2 3"
puts

# Calculate manually
reversed = base.reverse.chars.map(&:to_i)
weights = [2, 3, 4, 5, 6, 7, 8, 9, 2, 3]
products = reversed.zip(weights).map { |d, w| d * w }

puts "    4. Products:        #{products.join(' ')}"
sum = products.sum
puts "    5. Sum:             #{sum}"
puts "    6. Sum % 11:        #{sum % 11}"
puts "    7. 11 - (sum % 11): #{11 - (sum % 11)}"
calculated_dv = 11 - (sum % 11)
final_dv = calculated_dv >= 10 ? 0 : calculated_dv
puts "    8. Final DV:        #{final_dv} #{final_dv >= 10 ? '(>= 10, so use 0)' : ''}"
puts
puts "  Verification: #{final_dv == expected_dv ? '✓ Matches!' : '✗ Does not match'}"

# ============================================================================
# Section 6: Validating RENAVAM List
# ============================================================================
puts "\n6. Validating RENAVAM List"
puts "-" * 80

renavam_list = [
  '86769597308',
  '12345678901',
  '11111111111',
  '1234567890a',
  '12345678',
  '00000000000'
]

# Add some calculated valid ones
5.times do |i|
  base = (i * 987654321).to_s.rjust(10, '0')[0..9]
  dv = send(:calculate_renavam_dv, base + '0')
  renavam_list << (base + dv.to_s)
end

puts "  Validating #{renavam_list.length} RENAVAM numbers:"
puts

valid_count = 0
invalid_count = 0

renavam_list.each do |renavam|
  if valid?(renavam)
    valid_count += 1
    puts "    ✓ #{renavam}"
  else
    invalid_count += 1
    puts "    ✗ #{renavam.ljust(15)} [INVALID]"
  end
end

puts
puts "  Summary:"
puts "    Valid:   #{valid_count}"
puts "    Invalid: #{invalid_count}"
puts "    Total:   #{renavam_list.length}"

# ============================================================================
# Section 7: Batch Processing
# ============================================================================
puts "\n7. Batch Processing"
puts "-" * 80

puts "  Processing batch of vehicle registrations:"
puts

vehicles = [
  { plate: 'ABC-1234', renavam: '86769597308' },
  { plate: 'DEF-5678', renavam: '12345678901' },
  { plate: 'GHI-9012', renavam: '11111111111' }
]

# Add some valid vehicles
3.times do |i|
  base = (i * 123456789).to_s.rjust(10, '0')[0..9]
  dv = send(:calculate_renavam_dv, base + '0')
  vehicles << { plate: "XYZ-#{1000 + i}", renavam: base + dv.to_s }
end

valid_vehicles = []
invalid_vehicles = []

vehicles.each do |vehicle|
  if is_valid(vehicle[:renavam])
    valid_vehicles << vehicle
    puts "    ✓ #{vehicle[:plate].ljust(10)} - RENAVAM: #{vehicle[:renavam]}"
  else
    invalid_vehicles << vehicle
    puts "    ✗ #{vehicle[:plate].ljust(10)} - RENAVAM: #{vehicle[:renavam]} [INVALID]"
  end
end

puts
puts "  Summary:"
puts "    Valid vehicles:   #{valid_vehicles.length}"
puts "    Invalid vehicles: #{invalid_vehicles.length}"

# ============================================================================
# Section 8: Edge Cases - All Same Digits
# ============================================================================
puts "\n8. Edge Cases - All Same Digits"
puts "-" * 80

puts "  RENAVAM cannot be all the same digit:"

same_digit_renavams = [
  '00000000000',
  '11111111111',
  '22222222222',
  '99999999999'
]

same_digit_renavams.each do |renavam|
  valid = is_valid(renavam)
  status = valid ? '✓ VALID' : '✗ INVALID'
  puts "    #{renavam} → #{status}"
end

# ============================================================================
# Section 9: Edge Cases - Leading Zeros
# ============================================================================
puts "\n9. Edge Cases - Leading Zeros"
puts "-" * 80

puts "  RENAVAM can start with zeros (if checksum is valid):"

# Generate some with leading zeros
leading_zero_bases = ['0000000001', '0000000010', '0000000100', '0000001000']

leading_zero_bases.each do |base|
  dv = send(:calculate_renavam_dv, base + '0')
  renavam = base + dv.to_s
  valid = is_valid(renavam)
  status = valid ? '✓ VALID' : '✗ INVALID'
  puts "    #{renavam} → #{status}"
end

# ============================================================================
# Section 10: Edge Cases - Wrong Checksum
# ============================================================================
puts "\n10. Edge Cases - Wrong Checksum"
puts "-" * 80

puts "  Changing the verification digit makes RENAVAM invalid:"

valid_renavam = '86769597308'
correct_dv = valid_renavam[10]

puts "  Original: #{valid_renavam} (DV: #{correct_dv})"
puts "  Valid: #{is_valid(valid_renavam)}"
puts

(0..9).each do |dv|
  next if dv.to_s == correct_dv
  
  tampered = valid_renavam[0..9] + dv.to_s
  valid = is_valid(tampered)
  status = valid ? '✓ VALID' : '✗ INVALID'
  puts "    With DV #{dv}: #{tampered} → #{status}"
end

# ============================================================================
# Section 11: Calculating Verification Digits
# ============================================================================
puts "\n11. Calculating Verification Digits"
puts "-" * 80

puts "  Calculating DV for various base numbers:"
puts

test_bases_for_dv = [
  '0000000000',
  '1111111110',
  '1234567890',
  '9876543210',
  '0123456789'
]

test_bases_for_dv.each do |base|
  dv = send(:calculate_renavam_dv, base + '0')
  renavam = base + dv.to_s
  puts "    Base: #{base} → DV: #{dv} → RENAVAM: #{renavam}"
end

# ============================================================================
# Section 12: Weights Visualization
# ============================================================================
puts "\n12. Weights Visualization"
puts "-" * 80

puts "  The weights used for DV calculation:"
puts
puts "    Position (reversed): 1  2  3  4  5  6  7  8  9  10"
puts "    Weight:              2  3  4  5  6  7  8  9  2  3"
puts
puts "  Example with RENAVAM base '1234567890':"
puts "    Original:  1  2  3  4  5  6  7  8  9  0"
puts "    Reversed:  0  9  8  7  6  5  4  3  2  1"
puts "    Weights:   2  3  4  5  6  7  8  9  2  3"
puts "    Products:  0 27 32 35 36 35 32 27  4  3"

base = '1234567890'
reversed = base.reverse.chars.map(&:to_i)
weights = [2, 3, 4, 5, 6, 7, 8, 9, 2, 3]
products = reversed.zip(weights).map { |d, w| d * w }
sum = products.sum

puts "    Sum:      #{sum}"
puts "    Sum % 11: #{sum % 11}"
puts "    DV:       #{11 - (sum % 11)}"

# ============================================================================
# Section 13: Format Validation
# ============================================================================
puts "\n13. Format Validation"
puts "-" * 80

puts "  Testing various format issues:"
puts

format_tests = [
  { input: '86769597308', desc: 'Valid format' },
  { input: 12345678901, desc: 'Numeric (not string)' },
  { input: '123456789', desc: 'Too short (9 digits)' },
  { input: '12345678901', desc: 'Too long (12 digits)' },
  { input: '1234567890a', desc: 'Contains letter' },
  { input: '12345 67890', desc: 'Contains space' },
  { input: '12345-67890', desc: 'Contains hyphen' },
  { input: '123.456.789.01', desc: 'Contains dots' }
]

format_tests.each do |test|
  valid = is_valid_renavam(test[:input])
  status = valid ? '✓ VALID' : '✗ INVALID'
  puts "    #{status} #{test[:desc].ljust(25)} - Input: #{test[:input].inspect}"
end

# ============================================================================
# Section 14: Error Handling
# ============================================================================
puts "\n14. Error Handling"
puts "-" * 80

edge_cases = [
  nil,
  '',
  [],
  {},
  true,
  false
]

edge_cases.each do |input|
  puts "  Input: #{input.inspect.ljust(20)}"
  puts "    is_valid_renavam: #{is_valid_renavam(input)}"
  puts
end

# ============================================================================
# Section 15: Integration Example - Vehicle Database
# ============================================================================
puts "\n15. Integration Example - Vehicle Database"
puts "-" * 80

puts "  Simulating vehicle database validation:"
puts

vehicle_database = [
  { id: 1, owner: 'João Silva', renavam: '86769597308' },
  { id: 2, owner: 'Maria Santos', renavam: '12345678901' },
  { id: 3, owner: 'Pedro Costa', renavam: '11111111111' }
]

# Add some valid entries
3.times do |i|
  base = (i * 234567891).to_s.rjust(10, '0')[0..9]
  dv = send(:calculate_renavam_dv, base + '0')
  vehicle_database << {
    id: 4 + i,
    owner: "Owner #{4 + i}",
    renavam: base + dv.to_s
  }
end

puts "  Validating #{vehicle_database.length} vehicle records:"
puts

valid_records = []
invalid_records = []

vehicle_database.each do |vehicle|
  if valid?(vehicle[:renavam])
    valid_records << vehicle
    puts "    ✓ ID #{vehicle[:id]}: #{vehicle[:owner].ljust(20)} - RENAVAM: #{vehicle[:renavam]}"
  else
    invalid_records << vehicle
    puts "    ✗ ID #{vehicle[:id]}: #{vehicle[:owner].ljust(20)} - RENAVAM: #{vehicle[:renavam]} [INVALID]"
  end
end

puts
puts "  Database Statistics:"
puts "    Total records:   #{vehicle_database.length}"
puts "    Valid records:   #{valid_records.length}"
puts "    Invalid records: #{invalid_records.length}"
puts "    Data quality:    #{(valid_records.length * 100.0 / vehicle_database.length).round(1)}%"

# ============================================================================
# Section 16: Comprehensive Validation Test
# ============================================================================
puts "\n16. Comprehensive Validation Test"
puts "-" * 80

puts "  Generating and validating 20 calculated RENAVAMs:"
puts

all_valid = true

20.times do |i|
  base = (i * 50).to_s.rjust(10, '0')
  dv = send(:calculate_renavam_dv, base + '0')
  renavam = base + dv.to_s
  
  valid = is_valid(renavam)
  status = valid ? '✓' : '✗'
  all_valid = false unless valid
  
  puts "    #{status} #{i + 1}. #{renavam}"
end

puts
puts "  Result: #{all_valid ? '✓ All calculated RENAVAMs are valid!' : '✗ Some RENAVAMs are invalid'}"

# ============================================================================
# Section 17: RENAVAM Structure Visualization
# ============================================================================
puts "\n17. RENAVAM Structure Visualization"
puts "-" * 80

sample_renavam = '86769597308'

puts "  RENAVAM: #{sample_renavam}"
puts
puts "  Structure:"
puts "    #{sample_renavam}"
puts "    │││││││││││"
puts "    │││││││││││└─ Verification digit (position 11): #{sample_renavam[10]}"
puts "    └┴┴┴┴┴┴┴┴┴┴── Base number (positions 1-10): #{sample_renavam[0..9]}"
puts
puts "  Total length: 11 digits"

# ============================================================================
# Section 18: Comparison with Similar Systems
# ============================================================================
puts "\n18. Comparison with Similar Systems"
puts "-" * 80

puts "  RENAVAM characteristics:"
puts "    • Length: 11 digits"
puts "    • Format: No separators (continuous digits)"
puts "    • Checksum: Last digit (weights: 2,3,4,5,6,7,8,9,2,3)"
puts "    • Cannot be: All same digits"
puts "    • Purpose: Vehicle registration identification"
puts
puts "  Similar to:"
puts "    • CPF: 11 digits with checksum"
puts "    • PIS: 11 digits with checksum"
puts "    • Different from: License plates (letters + numbers)"

# ============================================================================
# Section 20: Best Practices
# ============================================================================
puts "\n20. Best Practices"
puts "-" * 80

puts "  When working with RENAVAM:"
puts
puts "  1. Always validate before storing in database"
puts "  2. Store as string to preserve leading zeros"
puts "  3. Do not accept formatted input (no separators)"
puts "  4. Reject all-same-digit patterns"
puts "  5. Verify checksum to ensure data integrity"
puts "  6. Consider adding validation at form input"
puts "  7. Log validation failures for security monitoring"
puts "  8. Use consistent method (is_valid, valid?, is_valid_renavam)"

puts "\n" + "=" * 80
puts "RENAVAM Utils Examples Complete!"
puts "=" * 80
