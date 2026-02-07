require 'brazilian-utils/license-plate-utils'

include BrazilianUtils::LicensePlateUtils

puts "=" * 80
puts "Brazilian License Plate Utils - Usage Examples"
puts "=" * 80

# ============================================================================
# Section 1: Format Detection
# ============================================================================
puts "\n1. Format Detection"
puts "-" * 80

plates_to_detect = [
  'ABC1234',
  'ABC-1234',
  'ABC1D34',
  'abc1d34',
  'XYZ9876'
]

plates_to_detect.each do |plate|
  format = get_format(plate)
  puts "  #{plate.ljust(15)} → Format: #{format || 'INVALID'}"
end

# ============================================================================
# Section 2: Old Format Validation
# ============================================================================
puts "\n2. Old Format Validation"
puts "-" * 80

old_format_plates = [
  'ABC1234',    # Valid
  'ABC-1234',   # Valid with dash
  'abc1234',    # Valid lowercase
  'XYZ9876',    # Valid
  'ABCD123',    # Invalid - 4 letters
  'ABC123',     # Invalid - too short
  'ABC1D34'     # Invalid - Mercosul format
]

old_format_plates.each do |plate|
  valid = is_valid(plate, :old_format)
  status = valid ? '✓ VALID' : '✗ INVALID'
  puts "  #{plate.ljust(15)} → #{status}"
end

# ============================================================================
# Section 3: Mercosul Format Validation
# ============================================================================
puts "\n3. Mercosul Format Validation"
puts "-" * 80

mercosul_plates = [
  'ABC1D34',    # Valid
  'abc1d34',    # Valid lowercase
  'XYZ2E56',    # Valid
  'ABC1234',    # Invalid - old format
  'ABC-1D34',   # Invalid - has dash
  'ABCD123'     # Invalid - wrong pattern
]

mercosul_plates.each do |plate|
  valid = is_valid(plate, :mercosul)
  status = valid ? '✓ VALID' : '✗ INVALID'
  puts "  #{plate.ljust(15)} → #{status}"
end

# ============================================================================
# Section 4: General Validation (Any Format)
# ============================================================================
puts "\n4. General Validation (Any Format)"
puts "-" * 80

mixed_plates = [
  'ABC1234',    # Valid old
  'ABC1D34',    # Valid Mercosul
  'ABC-1234',   # Valid old with dash
  'abc1d34',    # Valid Mercosul lowercase
  'ABCD123',    # Invalid
  '1234567',    # Invalid - only numbers
  'ABCDEFG'     # Invalid - only letters
]

mixed_plates.each do |plate|
  valid = is_valid(plate)
  format = get_format(plate)
  status = valid ? "✓ VALID (#{format})" : '✗ INVALID'
  puts "  #{plate.ljust(15)} → #{status}"
end

# ============================================================================
# Section 5: Using the valid? Alias
# ============================================================================
puts "\n5. Using the valid? Alias"
puts "-" * 80

test_plates = ['ABC1234', 'ABC1D34', 'INVALID']

test_plates.each do |plate|
  if valid?(plate)
    puts "  ✓ #{plate} is valid"
  else
    puts "  ✗ #{plate} is invalid"
  end
end

# ============================================================================
# Section 6: Formatting Old Format Plates
# ============================================================================
puts "\n6. Formatting Old Format Plates"
puts "-" * 80

old_plates_to_format = [
  'ABC1234',
  'abc1234',
  'ABC-1234',
  'xyz9876'
]

old_plates_to_format.each do |plate|
  formatted = format_license_plate(plate)
  puts "  #{plate.ljust(15)} → #{formatted}"
end

# ============================================================================
# Section 7: Formatting Mercosul Plates
# ============================================================================
puts "\n7. Formatting Mercosul Plates"
puts "-" * 80

mercosul_to_format = [
  'abc1d34',
  'ABC1D34',
  'xyz2e56',
  'XYZ2E56'
]

mercosul_to_format.each do |plate|
  formatted = format_license_plate(plate)
  puts "  #{plate.ljust(15)} → #{formatted}"
end

# ============================================================================
# Section 8: Using the format Alias
# ============================================================================
puts "\n8. Using the format Alias"
puts "-" * 80

plates_for_alias = ['ABC1234', 'ABC1D34', 'xyz9876']

plates_for_alias.each do |plate|
  formatted = format(plate)
  puts "  #{plate.ljust(15)} → #{formatted}"
end

# ============================================================================
# Section 9: Converting Old Format to Mercosul
# ============================================================================
puts "\n9. Converting Old Format to Mercosul"
puts "-" * 80

plates_to_convert = [
  'ABC0000',    # 0 → A
  'ABC1234',    # 2 → C
  'ABC4567',    # 5 → F
  'ABC9999',    # 9 → J
  'XYZ7890',    # 8 → I
  'abc-1234'    # lowercase with dash
]

plates_to_convert.each do |plate|
  mercosul = convert_to_mercosul(plate)
  if mercosul
    puts "  #{plate.ljust(15)} → #{mercosul} (digit #{plate.gsub('-', '')[4]} → letter #{mercosul[4]})"
  else
    puts "  #{plate.ljust(15)} → Cannot convert (invalid or already Mercosul)"
  end
end

# ============================================================================
# Section 10: Digit to Letter Conversion Table
# ============================================================================
puts "\n10. Digit to Letter Conversion Table"
puts "-" * 80

puts "  When converting old format to Mercosul, the 5th character (first digit) is converted:"
puts

(0..9).each do |digit|
  old_plate = "ABC#{digit}000"
  mercosul_plate = convert_to_mercosul(old_plate)
  letter = mercosul_plate[4] if mercosul_plate
  puts "    Digit #{digit} → Letter #{letter}   (Example: #{old_plate} → #{mercosul_plate})"
end

# ============================================================================
# Section 11: Removing Symbols
# ============================================================================
puts "\n11. Removing Symbols"
puts "-" * 80

plates_with_symbols = [
  'ABC-1234',
  'XYZ-9876',
  'ABC1234',
  'ABC1D34',
  'A-B-C-1-2-3-4'
]

plates_with_symbols.each do |plate|
  clean = remove_symbols(plate)
  puts "  #{plate.ljust(20)} → #{clean}"
end

# ============================================================================
# Section 12: Generating Random Old Format Plates
# ============================================================================
puts "\n12. Generating Random Old Format Plates"
puts "-" * 80

puts "  Generating 5 random old format plates (LLLNNNN):"
5.times do
  plate = generate('LLLNNNN')
  formatted = format_license_plate(plate)
  puts "    Generated: #{formatted} (raw: #{plate})"
end

# ============================================================================
# Section 13: Generating Random Mercosul Plates
# ============================================================================
puts "\n13. Generating Random Mercosul Plates"
puts "-" * 80

puts "  Generating 5 random Mercosul format plates (LLLNLNN):"
5.times do
  plate = generate('LLLNLNN')
  formatted = format_license_plate(plate)
  puts "    Generated: #{formatted}"
end

# ============================================================================
# Section 14: Generating with Default Format
# ============================================================================
puts "\n14. Generating with Default Format"
puts "-" * 80

puts "  Generating 3 plates with default format (Mercosul):"
3.times do
  plate = generate  # Defaults to 'LLLNLNN'
  puts "    Generated: #{plate}"
end

# ============================================================================
# Section 15: Complete Workflow Example
# ============================================================================
puts "\n15. Complete Workflow Example"
puts "-" * 80

puts "  Scenario: User enters an old format plate, validate and convert"
puts

user_input = 'abc-1234'
puts "  User input: #{user_input}"

if is_valid(user_input)
  # Get format
  format_type = get_format(user_input)
  puts "  Format detected: #{format_type}"
  
  # Format for display
  formatted = format_license_plate(user_input)
  puts "  Formatted: #{formatted}"
  
  # Remove symbols for storage
  clean = remove_symbols(user_input)
  puts "  Clean (for database): #{clean}"
  
  # Convert to Mercosul if old format
  if format_type == 'LLLNNNN'
    mercosul = convert_to_mercosul(user_input)
    puts "  Converted to Mercosul: #{mercosul}"
    
    mercosul_formatted = format_license_plate(mercosul)
    puts "  Mercosul formatted: #{mercosul_formatted}"
    
    # Verify the conversion is valid
    if is_valid(mercosul, :mercosul)
      puts "  ✓ Conversion successful and valid!"
    end
  else
    puts "  Already in Mercosul format - no conversion needed"
  end
else
  puts "  ✗ Invalid plate!"
end

# ============================================================================
# Section 16: Batch Processing Example
# ============================================================================
puts "\n16. Batch Processing Example"
puts "-" * 80

plate_database = [
  'ABC-1234',
  'DEF5678',
  'GHI1J23',
  'INVALID',
  'xyz-9876',
  'JKL2M34'
]

puts "  Processing #{plate_database.length} plates from database:"
puts

old_count = 0
mercosul_count = 0
invalid_count = 0

plate_database.each do |plate|
  if is_valid(plate)
    format_type = get_format(plate)
    
    if format_type == 'LLLNNNN'
      old_count += 1
      mercosul = convert_to_mercosul(plate)
      puts "    #{format_license_plate(plate).ljust(15)} [OLD] → #{mercosul} (converted)"
    else
      mercosul_count += 1
      puts "    #{format_license_plate(plate).ljust(15)} [MERCOSUL] (no conversion needed)"
    end
  else
    invalid_count += 1
    puts "    #{plate.ljust(15)} [INVALID]"
  end
end

puts
puts "  Summary:"
puts "    Old format: #{old_count}"
puts "    Mercosul format: #{mercosul_count}"
puts "    Invalid: #{invalid_count}"
puts "    Total: #{plate_database.length}"

# ============================================================================
# Section 17: Format-Specific Validation Example
# ============================================================================
puts "\n17. Format-Specific Validation Example"
puts "-" * 80

puts "  Scenario: System only accepts Mercosul format"
puts

test_plates_mercosul_only = ['ABC1234', 'ABC1D34', 'XYZ2E56']

test_plates_mercosul_only.each do |plate|
  if is_valid(plate, :mercosul)
    puts "    ✓ #{plate} accepted (Mercosul format)"
  else
    if is_valid(plate, :old_format)
      mercosul = convert_to_mercosul(plate)
      puts "    ⚠ #{plate} rejected (old format) - converted to #{mercosul}"
    else
      puts "    ✗ #{plate} rejected (invalid)"
    end
  end
end

# ============================================================================
# Section 18: Error Handling Example
# ============================================================================
puts "\n18. Error Handling Example"
puts "-" * 80

invalid_inputs = [
  nil,
  '',
  12345,
  'ABCD123',
  'ABC@1234',
  'ABC 1234'
]

invalid_inputs.each do |input|
  result = is_valid(input)
  format_result = get_format(input)
  convert_result = convert_to_mercosul(input) if input.is_a?(String)
  
  puts "  Input: #{input.inspect.ljust(20)}"
  puts "    is_valid: #{result}"
  puts "    get_format: #{format_result.inspect}"
  puts "    convert_to_mercosul: #{convert_result.inspect}" if input.is_a?(String)
  puts
end

# ============================================================================
# Section 19: Case Sensitivity Test
# ============================================================================
puts "\n19. Case Sensitivity Test"
puts "-" * 80

case_variations = [
  'ABC1234',    # Uppercase
  'abc1234',    # Lowercase
  'AbC1234',    # Mixed case
  'ABC1D34',    # Uppercase Mercosul
  'abc1d34',    # Lowercase Mercosul
  'AbC1d34'     # Mixed case Mercosul
]

case_variations.each do |plate|
  valid = is_valid(plate)
  formatted = format_license_plate(plate)
  status = valid ? '✓' : '✗'
  puts "  #{status} #{plate.ljust(15)} → #{formatted} (#{valid ? 'valid' : 'invalid'})"
end

# ============================================================================
# Section 20: Generation with Invalid Format
# ============================================================================
puts "\n20. Generation with Invalid Format"
puts "-" * 80

invalid_formats = [
  'LLLLNNN',    # Wrong pattern
  'INVALID',    # Not a pattern
  '',           # Empty
  'NNNNLLL'     # Reversed
]

invalid_formats.each do |format_str|
  result = generate(format_str)
  puts "  Format: #{format_str.ljust(15)} → Result: #{result.inspect}"
end

puts "\n" + "=" * 80
puts "License Plate Utils Examples Complete!"
puts "=" * 80
