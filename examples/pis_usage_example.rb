require 'brazilian-utils/pis-utils'

include BrazilianUtils::PISUtils

puts "=" * 80
puts "Brazilian PIS Utils - Usage Examples"
puts "=" * 80

# ============================================================================
# Section 1: Removing Symbols
# ============================================================================
puts "\n1. Removing Symbols"
puts "-" * 80

pis_with_symbols = [
  '123.45678.90-9',
  '987.65432.10-0',
  '12345678909',
  '123.456.789.09',
  '12345678-909',
  '1-2-3.4-5.6-7-8.9-0-9'
]

pis_with_symbols.each do |pis|
  clean = remove_symbols(pis)
  puts "  #{pis.ljust(25)} → #{clean}"
end

# ============================================================================
# Section 2: Using the sieve Alias
# ============================================================================
puts "\n2. Using the sieve Alias"
puts "-" * 80

puts "  sieve('123.45678.90-9') → #{sieve('123.45678.90-9')}"
puts "  sieve('987.65432.10-0') → #{sieve('987.65432.10-0')}"

# ============================================================================
# Section 3: Formatting Valid PIS Numbers
# ============================================================================
puts "\n3. Formatting Valid PIS Numbers"
puts "-" * 80

# Generate some valid PIS to demonstrate formatting
valid_pis_numbers = 5.times.map { generate }

valid_pis_numbers.each do |pis|
  formatted = format_pis(pis)
  puts "  #{pis.ljust(15)} → #{formatted}"
end

# ============================================================================
# Section 4: Formatting Known Valid PIS
# ============================================================================
puts "\n4. Formatting Known Valid PIS"
puts "-" * 80

known_valid = ['12345678909', '98765432100', '01234567890']

known_valid.each do |pis|
  formatted = format_pis(pis)
  if formatted
    puts "  #{pis.ljust(15)} → #{formatted}"
  else
    puts "  #{pis.ljust(15)} → Cannot format (invalid)"
  end
end

# ============================================================================
# Section 5: Using the format Alias
# ============================================================================
puts "\n5. Using the format Alias"
puts "-" * 80

test_pis = generate
puts "  Generated: #{test_pis}"
puts "  format(#{test_pis}) → #{format(test_pis)}"

# ============================================================================
# Section 6: Formatting Invalid PIS (Returns nil)
# ============================================================================
puts "\n6. Formatting Invalid PIS (Returns nil)"
puts "-" * 80

invalid_pis = [
  '12345678900',
  '123456789',
  '123456789012',
  '1234567890A'
]

invalid_pis.each do |pis|
  formatted = format_pis(pis)
  puts "  #{pis.ljust(15)} → #{formatted.inspect}"
end

# ============================================================================
# Section 7: Validating Valid PIS Numbers
# ============================================================================
puts "\n7. Validating Valid PIS Numbers"
puts "-" * 80

valid_numbers = [
  '12345678909',
  '98765432100',
  '01234567890',
  '12082043600',
  '17033259504'
]

valid_numbers.each do |pis|
  valid = is_valid(pis)
  status = valid ? '✓ VALID' : '✗ INVALID'
  puts "  #{pis.ljust(15)} → #{status}"
end

# ============================================================================
# Section 8: Validating Invalid PIS Numbers
# ============================================================================
puts "\n8. Validating Invalid PIS Numbers"
puts "-" * 80

invalid_numbers = [
  '12345678900',      # Wrong checksum
  '12345678908',      # Wrong checksum
  '123456789',        # Too short
  '123456789012',     # Too long
  '1234567890A',      # Contains letter
  '123.45678.90-9',   # Contains symbols
  '00000000000',      # All zeros
  '11111111111'       # All ones
]

invalid_numbers.each do |pis|
  valid = is_valid(pis)
  status = valid ? '✓ VALID' : '✗ INVALID'
  puts "  #{pis.ljust(20)} → #{status}"
end

# ============================================================================
# Section 9: Using the valid? Alias
# ============================================================================
puts "\n9. Using the valid? Alias"
puts "-" * 80

test_numbers = ['12345678909', '98765432100', '12345678900']

test_numbers.each do |pis|
  if valid?(pis)
    puts "  ✓ #{pis} is valid"
  else
    puts "  ✗ #{pis} is invalid"
  end
end

# ============================================================================
# Section 10: Generating Random PIS Numbers
# ============================================================================
puts "\n10. Generating Random PIS Numbers"
puts "-" * 80

puts "  Generating 10 random PIS numbers:"
10.times do
  pis = generate
  formatted = format(pis)
  puts "    #{formatted.ljust(20)} (#{pis})"
end

# ============================================================================
# Section 11: Verifying Generated PIS Are Valid
# ============================================================================
puts "\n11. Verifying Generated PIS Are Valid"
puts "-" * 80

puts "  Generating 5 PIS and validating each:"
5.times do |i|
  pis = generate
  valid = is_valid(pis)
  status = valid ? '✓' : '✗'
  puts "    #{status} PIS #{i + 1}: #{format(pis)}"
end

# ============================================================================
# Section 12: Complete Workflow - User Input with Symbols
# ============================================================================
puts "\n12. Complete Workflow - User Input with Symbols"
puts "-" * 80

user_input = '123.45678.90-9'

puts "  User input: #{user_input}"
puts

# Step 1: Remove symbols
clean = remove_symbols(user_input)
puts "  1. After remove_symbols: #{clean}"

# Step 2: Validate
if is_valid(clean)
  puts "  2. Validation: ✓ VALID"
  
  # Step 3: Format for display
  formatted = format_pis(clean)
  puts "  3. Formatted: #{formatted}"
  
  # Step 4: Store cleaned version
  puts "  4. Store in database: #{clean}"
else
  puts "  2. Validation: ✗ INVALID"
end

# ============================================================================
# Section 13: Complete Workflow - Invalid Input
# ============================================================================
puts "\n13. Complete Workflow - Invalid Input"
puts "-" * 80

invalid_input = '123.45678.90-0'

puts "  User input: #{invalid_input}"
puts

# Step 1: Remove symbols
clean = remove_symbols(invalid_input)
puts "  1. After remove_symbols: #{clean}"

# Step 2: Validate
if is_valid(clean)
  puts "  2. Validation: ✓ VALID"
  formatted = format_pis(clean)
  puts "  3. Formatted: #{formatted}"
else
  puts "  2. Validation: ✗ INVALID (wrong checksum)"
  puts "  3. Cannot format invalid PIS"
end

# ============================================================================
# Section 14: Validating PIS List
# ============================================================================
puts "\n14. Validating PIS List"
puts "-" * 80

pis_list = [
  '123.45678.90-9',
  '98765432100',
  '12345678900',
  '123456789',
  '12082043600',
  '17033259504',
  '00000000000'
]

puts "  Validating #{pis_list.length} PIS numbers:"
puts

valid_count = 0
invalid_count = 0

pis_list.each do |pis|
  # Clean if needed
  clean = remove_symbols(pis)
  
  if valid?(clean)
    valid_count += 1
    formatted = format(clean)
    puts "    ✓ #{formatted.ljust(20)}"
  else
    invalid_count += 1
    puts "    ✗ #{pis.ljust(20)} [INVALID]"
  end
end

puts
puts "  Summary:"
puts "    Valid: #{valid_count}"
puts "    Invalid: #{invalid_count}"
puts "    Total: #{pis_list.length}"

# ============================================================================
# Section 15: Generating Test Data
# ============================================================================
puts "\n15. Generating Test Data"
puts "-" * 80

puts "  Generating test dataset with 10 PIS numbers:"
puts

test_data = 10.times.map { generate }

test_data.each_with_index do |pis, index|
  formatted = format(pis)
  puts "    #{(index + 1).to_s.rjust(2)}. #{formatted} (#{pis})"
end

# ============================================================================
# Section 16: Format and Clean Are Inverse Operations
# ============================================================================
puts "\n16. Format and Clean Are Inverse Operations"
puts "-" * 80

puts "  Testing format → clean → format cycle:"
5.times do |i|
  original = generate
  formatted = format(original)
  cleaned = remove_symbols(formatted)
  reformatted = format(cleaned)
  
  match = (original == cleaned && formatted == reformatted)
  status = match ? '✓' : '✗'
  
  puts "    #{status} Cycle #{i + 1}: #{original} → #{formatted} → #{cleaned} → #{reformatted}"
end

# ============================================================================
# Section 17: Checksum Verification
# ============================================================================
puts "\n17. Checksum Verification"
puts "-" * 80

puts "  Understanding checksum calculation:"
puts

# Generate a PIS and explain its checksum
pis = generate
base = pis[0..9]
checksum_digit = pis[10]

puts "  PIS: #{format(pis)}"
puts "  Base (first 10 digits): #{base}"
puts "  Checksum digit (11th digit): #{checksum_digit}"
puts
puts "  Checksum calculation:"
puts "    Digits:  #{base.chars.join('  ')}"
puts "    Weights: 3  2  9  8  7  6  5  4  3  2"
puts
puts "  Algorithm:"
puts "    1. Multiply each digit by its weight"
puts "    2. Sum all products"
puts "    3. Calculate: 11 - (sum % 11)"
puts "    4. If result is 10 or 11, use 0"
puts "    5. Result is the checksum digit"

# ============================================================================
# Section 18: PIS Starting with Zeros
# ============================================================================
puts "\n18. PIS Starting with Zeros"
puts "-" * 80

puts "  PIS numbers can start with zeros:"
puts

# Generate until we get one starting with 0 (or create examples)
examples = []
50.times do
  pis = generate
  examples << pis if pis[0] == '0'
  break if examples.length >= 3
end

if examples.any?
  examples.each do |pis|
    formatted = format(pis)
    puts "    #{formatted} (#{pis})"
  end
else
  puts "    (Generating PIS with leading zeros is rare but valid)"
  puts "    Example format: 012.34567.89-0"
end

# ============================================================================
# Section 19: Batch Processing
# ============================================================================
puts "\n19. Batch Processing"
puts "-" * 80

puts "  Processing batch of user inputs:"
puts

user_inputs = [
  '123.45678.90-9',
  '987.65432.10-0',
  '12345678900',
  '123456789',
  '12082043600',
  '987-654-321-00'
]

results = {
  valid: [],
  invalid: []
}

user_inputs.each do |input|
  clean = remove_symbols(input)
  
  if valid?(clean)
    results[:valid] << { original: input, clean: clean, formatted: format(clean) }
  else
    results[:invalid] << { original: input, clean: clean }
  end
end

puts "  Valid PIS (#{results[:valid].length}):"
results[:valid].each do |item|
  puts "    ✓ #{item[:formatted]}"
end

puts
puts "  Invalid PIS (#{results[:invalid].length}):"
results[:invalid].each do |item|
  puts "    ✗ #{item[:original]} (cleaned: #{item[:clean]})"
end

# ============================================================================
# Section 20: Error Handling
# ============================================================================
puts "\n20. Error Handling"
puts "-" * 80

edge_cases = [
  nil,
  '',
  12345678909,
  'ABC123DEF456',
  '123.45678.90-9',
  '12345678909 '
]

edge_cases.each do |input|
  puts "  Input: #{input.inspect.ljust(25)}"
  puts "    is_valid: #{is_valid(input)}"
  puts "    format_pis: #{format_pis(input).inspect}"
  
  if input.is_a?(String) && !input.empty?
    clean = remove_symbols(input)
    puts "    remove_symbols: #{clean.inspect}"
  end
  
  puts
end

# ============================================================================
# Section 21: PIS Structure Visualization
# ============================================================================
puts "\n21. PIS Structure Visualization"
puts "-" * 80

sample_pis = generate
formatted = format(sample_pis)

puts "  PIS: #{formatted}"
puts
puts "  Structure breakdown:"
puts "    #{formatted}"
puts "    │   │     │  └─ Checksum digit (calculated)"
puts "    │   │     └──── Digits 9-10"
puts "    │   └────────── Digits 4-8 (5 digits)"
puts "    └────────────── Digits 1-3 (3 digits)"
puts
puts "  Raw format: #{sample_pis}"
puts "    Positions: 1234567890X (X = checksum)"

# ============================================================================
# Section 22: Statistics on Generated PIS
# ============================================================================
puts "\n22. Statistics on Generated PIS"
puts "-" * 80

puts "  Generating 100 PIS and analyzing:"
puts

generated = 100.times.map { generate }

# Check how many start with each digit
digit_distribution = Hash.new(0)
generated.each do |pis|
  digit_distribution[pis[0]] += 1
end

puts "  First digit distribution:"
('0'..'9').each do |digit|
  count = digit_distribution[digit]
  percentage = (count * 100.0 / generated.length).round(1)
  bar = '█' * (count / 2)
  puts "    #{digit}: #{bar} #{count} (#{percentage}%)"
end

# Check all are valid
all_valid = generated.all? { |pis| is_valid(pis) }
puts
puts "  All generated PIS are valid: #{all_valid ? '✓ YES' : '✗ NO'}"

# ============================================================================
# Section 23: Comparison with Formatted Input
# ============================================================================
puts "\n23. Comparison with Formatted Input"
puts "-" * 80

puts "  Comparing raw and formatted input validation:"
puts

comparison_pis = generate

puts "  Original: #{comparison_pis}"
puts "    is_valid(#{comparison_pis}): #{is_valid(comparison_pis)}"
puts

formatted_pis = format(comparison_pis)
puts "  Formatted: #{formatted_pis}"
puts "    is_valid(#{formatted_pis}): #{is_valid(formatted_pis)}"
puts

cleaned_pis = remove_symbols(formatted_pis)
puts "  Cleaned: #{cleaned_pis}"
puts "    is_valid(#{cleaned_pis}): #{is_valid(cleaned_pis)}"
puts
puts "  Note: Validation requires cleaned (digits-only) input"

# ============================================================================
# Section 24: Database Storage Example
# ============================================================================
puts "\n24. Database Storage Example"
puts "-" * 80

puts "  Best practices for storing PIS in database:"
puts

user_form_input = '123.45678.90-9'

puts "  1. User enters: #{user_form_input}"

# Clean
stored_value = remove_symbols(user_form_input)
puts "  2. Store in database: #{stored_value} (digits only)"

# Validate before storing
if valid?(stored_value)
  puts "  3. Validation: ✓ Valid - safe to store"
  
  # When displaying
  display_value = format(stored_value)
  puts "  4. Display to user: #{display_value}"
else
  puts "  3. Validation: ✗ Invalid - reject input"
end

# ============================================================================
# Section 25: Integration with Other Systems
# ============================================================================
puts "\n25. Integration with Other Systems"
puts "-" * 80

puts "  Example: Processing PIS from external API:"
puts

# Simulate API response
api_responses = [
  { name: 'João Silva', pis: '123.45678.90-9' },
  { name: 'Maria Santos', pis: '98765432100' },
  { name: 'Pedro Costa', pis: '12345678900' }  # Invalid
]

puts "  Processing #{api_responses.length} records:"
puts

valid_records = []
invalid_records = []

api_responses.each do |record|
  clean_pis = remove_symbols(record[:pis])
  
  if valid?(clean_pis)
    valid_records << record.merge(clean_pis: clean_pis, formatted_pis: format(clean_pis))
    puts "    ✓ #{record[:name].ljust(20)} - PIS: #{format(clean_pis)}"
  else
    invalid_records << record
    puts "    ✗ #{record[:name].ljust(20)} - PIS: #{record[:pis]} [INVALID]"
  end
end

puts
puts "  Summary:"
puts "    Valid records: #{valid_records.length}"
puts "    Invalid records: #{invalid_records.length}"

puts "\n" + "=" * 80
puts "PIS Utils Examples Complete!"
puts "=" * 80
