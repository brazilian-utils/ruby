require 'brazilian-utils/phone-utils'

include BrazilianUtils::PhoneUtils

puts "=" * 80
puts "Brazilian Phone Utils - Usage Examples"
puts "=" * 80

# ============================================================================
# Section 1: Formatting Mobile Numbers
# ============================================================================
puts "\n1. Formatting Mobile Numbers"
puts "-" * 80

mobile_numbers = [
  '11994029275',
  '21987654321',
  '85912345678',
  '47999887766'
]

mobile_numbers.each do |phone|
  formatted = format_phone(phone)
  puts "  #{phone.ljust(15)} → #{formatted}"
end

# ============================================================================
# Section 2: Formatting Landline Numbers
# ============================================================================
puts "\n2. Formatting Landline Numbers"
puts "-" * 80

landline_numbers = [
  '1635014415',
  '1122334455',
  '2133445566',
  '8544556677',
  '4755667788'
]

landline_numbers.each do |phone|
  formatted = format_phone(phone)
  puts "  #{phone.ljust(15)} → #{formatted}"
end

# ============================================================================
# Section 3: Using the format Alias
# ============================================================================
puts "\n3. Using the format Alias"
puts "-" * 80

test_phones = ['11994029275', '1635014415', '21987654321']

test_phones.each do |phone|
  formatted = format(phone)
  puts "  #{phone.ljust(15)} → #{formatted}"
end

# ============================================================================
# Section 4: Validating Any Type (Default)
# ============================================================================
puts "\n4. Validating Any Type (Default)"
puts "-" * 80

all_types = [
  '11994029275',    # Valid mobile
  '1635014415',     # Valid landline
  '21987654321',    # Valid mobile
  '1122334455',     # Valid landline
  '123456',         # Invalid - too short
  '01987654321',    # Invalid - DDD starts with 0
  '1166778899',     # Invalid - landline with 6 after DDD
  ''                # Invalid - empty
]

all_types.each do |phone|
  valid = is_valid(phone)
  status = valid ? '✓ VALID' : '✗ INVALID'
  puts "  #{phone.ljust(20)} → #{status}"
end

# ============================================================================
# Section 5: Validating Mobile Numbers Only
# ============================================================================
puts "\n5. Validating Mobile Numbers Only"
puts "-" * 80

mobile_tests = [
  '11994029275',    # Valid mobile
  '21987654321',    # Valid mobile
  '85912345678',    # Valid mobile
  '1635014415',     # Invalid - landline
  '11887654321',    # Invalid - no 9 after DDD
  '123456'          # Invalid - too short
]

mobile_tests.each do |phone|
  valid = is_valid(phone, :mobile)
  status = valid ? '✓ VALID MOBILE' : '✗ NOT MOBILE'
  puts "  #{phone.ljust(20)} → #{status}"
end

# ============================================================================
# Section 6: Validating Landline Numbers Only
# ============================================================================
puts "\n6. Validating Landline Numbers Only"
puts "-" * 80

landline_tests = [
  '1635014415',     # Valid landline
  '1122334455',     # Valid landline (starts with 2)
  '2133445566',     # Valid landline (starts with 3)
  '8544556677',     # Valid landline (starts with 4)
  '4755667788',     # Valid landline (starts with 5)
  '11994029275',    # Invalid - mobile
  '1166778899',     # Invalid - starts with 6
  '123456'          # Invalid - too short
]

landline_tests.each do |phone|
  valid = is_valid(phone, :landline)
  status = valid ? '✓ VALID LANDLINE' : '✗ NOT LANDLINE'
  puts "  #{phone.ljust(20)} → #{status}"
end

# ============================================================================
# Section 7: Using String Type Parameter
# ============================================================================
puts "\n7. Using String Type Parameter"
puts "-" * 80

puts "  Testing with 'mobile' string:"
puts "    11994029275 → #{is_valid('11994029275', 'mobile')}"
puts "    1635014415  → #{is_valid('1635014415', 'mobile')}"

puts "\n  Testing with 'landline' string:"
puts "    1635014415  → #{is_valid('1635014415', 'landline')}"
puts "    11994029275 → #{is_valid('11994029275', 'landline')}"

# ============================================================================
# Section 8: Using the valid? Alias
# ============================================================================
puts "\n8. Using the valid? Alias"
puts "-" * 80

test_numbers = ['11994029275', '1635014415', 'INVALID123']

test_numbers.each do |phone|
  if valid?(phone)
    puts "  ✓ #{phone} is valid"
  else
    puts "  ✗ #{phone} is invalid"
  end
end

# ============================================================================
# Section 9: Removing Symbols
# ============================================================================
puts "\n9. Removing Symbols"
puts "-" * 80

phones_with_symbols = [
  '(11)994029275',
  '11-99402-9275',
  '+5511994029275',
  '11 99402 9275',
  '+55 (11) 99402-9275',
  '(16) 3501-4415'
]

phones_with_symbols.each do |phone|
  clean = remove_symbols_phone(phone)
  puts "  #{phone.ljust(25)} → #{clean}"
end

# ============================================================================
# Section 10: Using remove_symbols Alias
# ============================================================================
puts "\n10. Using remove_symbols Alias"
puts "-" * 80

puts "  remove_symbols:"
puts "    (11)99402-9275 → #{remove_symbols('(11)99402-9275')}"

puts "\n  sieve:"
puts "    +55 11 99402-9275 → #{sieve('+55 11 99402-9275')}"

# ============================================================================
# Section 11: Removing International Dialing Code
# ============================================================================
puts "\n11. Removing International Dialing Code"
puts "-" * 80

international_numbers = [
  '5511994029275',
  '+5511994029275',
  '551635014415',
  '+551635014415',
  '11994029275',
  '1635014415',
  '555511994029275'
]

international_numbers.each do |phone|
  without_code = remove_international_dialing_code(phone)
  puts "  #{phone.ljust(20)} → #{without_code}"
end

# ============================================================================
# Section 12: Generating Random Type (Default)
# ============================================================================
puts "\n12. Generating Random Type (Default)"
puts "-" * 80

puts "  Generating 5 random phone numbers (mobile or landline):"
5.times do
  phone = generate
  type = is_valid(phone, :mobile) ? 'Mobile' : 'Landline'
  formatted = format_phone(phone)
  puts "    #{formatted.ljust(20)} [#{type}] (#{phone})"
end

# ============================================================================
# Section 13: Generating Mobile Numbers
# ============================================================================
puts "\n13. Generating Mobile Numbers"
puts "-" * 80

puts "  Generating 5 mobile numbers:"
5.times do
  phone = generate(:mobile)
  formatted = format_phone(phone)
  puts "    #{formatted.ljust(20)} (#{phone}) - 3rd digit: #{phone[2]}"
end

# ============================================================================
# Section 14: Generating Landline Numbers
# ============================================================================
puts "\n14. Generating Landline Numbers"
puts "-" * 80

puts "  Generating 5 landline numbers:"
5.times do
  phone = generate(:landline)
  formatted = format_phone(phone)
  puts "    #{formatted.ljust(20)} (#{phone}) - 3rd digit: #{phone[2]}"
end

# ============================================================================
# Section 15: Using String Type for Generation
# ============================================================================
puts "\n15. Using String Type for Generation"
puts "-" * 80

puts "  Generating with 'mobile' string:"
3.times do
  phone = generate('mobile')
  puts "    #{format(phone)}"
end

puts "\n  Generating with 'landline' string:"
3.times do
  phone = generate('landline')
  puts "    #{format(phone)}"
end

# ============================================================================
# Section 16: Complete Workflow - User Input with International Code
# ============================================================================
puts "\n16. Complete Workflow - User Input with International Code"
puts "-" * 80

user_input = '+55 (11) 99402-9275'

puts "  User input: #{user_input}"
puts

# Step 1: Remove symbols
clean = remove_symbols(user_input)
puts "  1. After remove_symbols: #{clean}"

# Step 2: Remove international code
without_code = remove_international_dialing_code(clean)
puts "  2. After remove_international_dialing_code: #{without_code}"

# Step 3: Validate
if is_valid(without_code)
  puts "  3. Validation: ✓ VALID"
  
  # Step 4: Check type
  if is_valid(without_code, :mobile)
    puts "  4. Type: Mobile"
  elsif is_valid(without_code, :landline)
    puts "  4. Type: Landline"
  end
  
  # Step 5: Format for display
  formatted = format_phone(without_code)
  puts "  5. Formatted: #{formatted}"
else
  puts "  3. Validation: ✗ INVALID"
end

# ============================================================================
# Section 17: Complete Workflow - Landline
# ============================================================================
puts "\n17. Complete Workflow - Landline"
puts "-" * 80

landline_input = '(16) 3501-4415'

puts "  User input: #{landline_input}"
puts

# Clean
clean = remove_symbols(landline_input)
puts "  1. After remove_symbols: #{clean}"

# Validate
if valid?(clean)
  puts "  2. Validation: ✓ VALID"
  
  # Check type
  if valid?(clean, :mobile)
    puts "  3. Type: Mobile"
  elsif valid?(clean, :landline)
    puts "  3. Type: Landline"
  end
  
  # Format
  formatted = format(clean)
  puts "  4. Formatted: #{formatted}"
else
  puts "  2. Validation: ✗ INVALID"
end

# ============================================================================
# Section 18: Validating Phone List
# ============================================================================
puts "\n18. Validating Phone List"
puts "-" * 80

phone_list = [
  '11994029275',
  '1635014415',
  '(21)98765-4321',
  '+5585912345678',
  '123456',
  '01987654321',
  '1166778899'
]

puts "  Validating #{phone_list.length} phone numbers:"
puts

valid_count = 0
invalid_count = 0

phone_list.each do |phone|
  # Clean if needed
  clean = remove_symbols(phone)
  clean = remove_international_dialing_code(clean)
  
  if valid?(clean)
    valid_count += 1
    type = valid?(clean, :mobile) ? 'Mobile' : 'Landline'
    formatted = format(clean)
    puts "    ✓ #{formatted.ljust(20)} [#{type}]"
  else
    invalid_count += 1
    puts "    ✗ #{phone.ljust(20)} [INVALID]"
  end
end

puts
puts "  Summary:"
puts "    Valid: #{valid_count}"
puts "    Invalid: #{invalid_count}"
puts "    Total: #{phone_list.length}"

# ============================================================================
# Section 19: Generating Test Data
# ============================================================================
puts "\n19. Generating Test Data"
puts "-" * 80

puts "  Generating test dataset with 10 phones (5 mobile, 5 landline):"
puts

test_data = []

puts "  Mobile numbers:"
5.times do
  phone = generate(:mobile)
  test_data << { number: phone, type: 'mobile' }
  puts "    #{format(phone)}"
end

puts "\n  Landline numbers:"
5.times do
  phone = generate(:landline)
  test_data << { number: phone, type: 'landline' }
  puts "    #{format(phone)}"
end

puts "\n  Verifying all generated numbers are valid:"
test_data.each do |data|
  valid = is_valid(data[:number], data[:type].to_sym)
  status = valid ? '✓' : '✗'
  puts "    #{status} #{format(data[:number])} [#{data[:type]}]"
end

# ============================================================================
# Section 20: Phone Type Detection
# ============================================================================
puts "\n20. Phone Type Detection"
puts "-" * 80

mixed_phones = [
  '11994029275',
  '1635014415',
  '21987654321',
  '1122334455',
  '85912345678',
  '4755667788'
]

puts "  Detecting phone types:"
mixed_phones.each do |phone|
  if is_valid(phone, :mobile)
    type = 'Mobile'
    pattern = 'DDD + 9 + 8 digits'
  elsif is_valid(phone, :landline)
    type = 'Landline'
    digit = phone[2]
    pattern = "DDD + #{digit} + 7 digits"
  else
    type = 'Invalid'
    pattern = 'N/A'
  end
  
  formatted = format(phone) || phone
  puts "    #{formatted.ljust(20)} → #{type.ljust(10)} (#{pattern})"
end

# ============================================================================
# Section 21: Error Handling
# ============================================================================
puts "\n21. Error Handling"
puts "-" * 80

invalid_inputs = [
  nil,
  '',
  123456,
  'ABC123DEF456',
  '(11)99402-9275',  # Has symbols
  '00987654321',     # DDD starts with 0
  '1199001122'       # 10 digits starting with 9 (neither mobile nor landline)
]

invalid_inputs.each do |input|
  puts "  Input: #{input.inspect.ljust(25)}"
  puts "    is_valid: #{is_valid(input)}"
  puts "    format_phone: #{format_phone(input).inspect}"
  
  if input.is_a?(String) && !input.empty?
    clean = remove_symbols(input)
    puts "    remove_symbols: #{clean.inspect}"
  end
  
  puts
end

# ============================================================================
# Section 22: DDD (Area Code) Examples
# ============================================================================
puts "\n22. DDD (Area Code) Examples"
puts "-" * 80

ddd_examples = [
  { ddd: '11', city: 'São Paulo (SP)', mobile: '11987654321', landline: '1133221100' },
  { ddd: '21', city: 'Rio de Janeiro (RJ)', mobile: '21987654321', landline: '2133221100' },
  { ddd: '85', city: 'Fortaleza (CE)', mobile: '85987654321', landline: '8533221100' },
  { ddd: '47', city: 'Joinville/Blumenau (SC)', mobile: '47987654321', landline: '4733221100' },
  { ddd: '51', city: 'Porto Alegre (RS)', mobile: '51987654321', landline: '5133221100' }
]

ddd_examples.each do |example|
  puts "  DDD #{example[:ddd]} - #{example[:city]}"
  puts "    Mobile:   #{format(example[:mobile])}"
  puts "    Landline: #{format(example[:landline])}"
  puts
end

# ============================================================================
# Section 23: Reverse Operation (Format → Clean → Format)
# ============================================================================
puts "\n23. Reverse Operation (Format → Clean → Format)"
puts "-" * 80

original_numbers = ['11994029275', '1635014415']

original_numbers.each do |phone|
  # Format
  formatted = format(phone)
  puts "  Original: #{phone}"
  puts "    1. Formatted: #{formatted}"
  
  # Remove symbols (clean)
  cleaned = remove_symbols(formatted)
  puts "    2. Cleaned: #{cleaned}"
  
  # Format again
  reformatted = format(cleaned)
  puts "    3. Reformatted: #{reformatted}"
  
  # Verify they match
  match = (formatted == reformatted)
  puts "    4. Match: #{match ? '✓ YES' : '✗ NO'}"
  puts
end

# ============================================================================
# Section 24: Batch Generation with Statistics
# ============================================================================
puts "\n24. Batch Generation with Statistics"
puts "-" * 80

puts "  Generating 20 random phones and analyzing distribution:"
puts

generated = 20.times.map { generate }

mobile_count = generated.count { |p| is_valid(p, :mobile) }
landline_count = generated.count { |p| is_valid(p, :landline) }

puts "  Statistics:"
puts "    Total generated: #{generated.length}"
puts "    Mobile: #{mobile_count} (#{(mobile_count * 100.0 / generated.length).round(1)}%)"
puts "    Landline: #{landline_count} (#{(landline_count * 100.0 / generated.length).round(1)}%)"
puts
puts "  Sample (first 5):"
generated.first(5).each do |phone|
  type = is_valid(phone, :mobile) ? 'Mobile' : 'Landline'
  puts "    #{format(phone).ljust(20)} [#{type}]"
end

# ============================================================================
# Section 25: Format Comparison Table
# ============================================================================
puts "\n25. Format Comparison Table"
puts "-" * 80

puts "  Mobile vs Landline Comparison:"
puts
puts "  Aspect          | Mobile              | Landline"
puts "  ----------------|---------------------|--------------------"
puts "  Total Digits    | 11                  | 10"
puts "  Pattern         | (DD)9NNNN-NNNN      | (DD)NNNN-NNNN"
puts "  DDD             | 2 digits (11-99)    | 2 digits (11-99)"
puts "  3rd Digit       | Always 9            | 2, 3, 4, or 5"
puts "  Example         | (11)99402-9275      | (16)3501-4415"
puts "  Raw Format      | 11994029275         | 1635014415"
puts

# ============================================================================
# Section 26: International Code Scenarios
# ============================================================================
puts "\n26. International Code Scenarios"
puts "-" * 80

intl_scenarios = [
  { input: '5511994029275', expected: '11994029275', description: 'Mobile with 55' },
  { input: '+5511994029275', expected: '+11994029275', description: 'Mobile with +55' },
  { input: '551635014415', expected: '1635014415', description: 'Landline with 55' },
  { input: '11994029275', expected: '11994029275', description: 'Mobile without code' },
  { input: '555511994029275', expected: '5511994029275', description: 'Double 55 (removes first)' }
]

intl_scenarios.each do |scenario|
  result = remove_international_dialing_code(scenario[:input])
  match = (result == scenario[:expected])
  status = match ? '✓' : '✗'
  
  puts "  #{status} #{scenario[:description]}"
  puts "      Input:    #{scenario[:input]}"
  puts "      Expected: #{scenario[:expected]}"
  puts "      Result:   #{result}"
  puts
end

puts "=" * 80
puts "Phone Utils Examples Complete!"
puts "=" * 80
