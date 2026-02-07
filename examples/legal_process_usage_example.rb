require_relative '../lib/brazilian-utils/legal-process-utils'

puts "=" * 80
puts "Brazilian Legal Process Utils - Usage Examples"
puts "=" * 80
puts

# ============================================================================
# Format Information
# ============================================================================
puts "LEGAL PROCESS ID FORMAT"
puts "-" * 80
puts "Format: NNNNNNN-DD.AAAA.J.TR.OOOO"
puts
puts "Where:"
puts "  NNNNNNN = Sequential number (7 digits)"
puts "  DD      = Verification digits (2 digits) - checksum"
puts "  AAAA    = Year the process was filed (4 digits)"
puts "  J       = Judicial segment (1 digit) - Órgão (1-9)"
puts "  TR      = Court (2 digits) - Tribunal"
puts "  OOOO    = Court of origin (4 digits) - Foro"
puts
puts "Órgãos (Judicial Segments):"
puts "  1 = Supremo Tribunal Federal (STF)"
puts "  2 = Conselho Nacional de Justiça (CNJ)"
puts "  3 = Justiça Militar"
puts "  4 = Justiça Eleitoral"
puts "  5 = Justiça do Trabalho"
puts "  6 = Justiça Federal"
puts "  7 = Justiça Estadual"
puts "  8 = Justiça dos Estados e do Distrito Federal"
puts "  9 = Justiça Militar Estadual"
puts

# ============================================================================
# Removing Symbols
# ============================================================================
puts "1. REMOVING SYMBOLS"
puts "-" * 80

formatted_ids = [
  '1234567-89.0123.4.56.7890',
  '9876543-21.0987.6.54.3210',
  '6847650-60.2023.3.03.0000',
  '5180823-36.2023.3.03.0000'
]

puts "Removing dots and hyphens from formatted IDs:"
formatted_ids.each do |formatted|
  clean = BrazilianUtils::LegalProcessUtils.remove_symbols(formatted)
  puts "  #{formatted} => #{clean}"
end
puts

# ============================================================================
# Formatting Legal Process IDs
# ============================================================================
puts "2. FORMATTING LEGAL PROCESS IDs"
puts "-" * 80

unformatted_ids = [
  '12345678901234567890',
  '98765432109876543210',
  '68476506020233030000',
  '51808233620233030000'
]

puts "Formatting 20-digit IDs:"
unformatted_ids.each do |id|
  formatted = BrazilianUtils::LegalProcessUtils.format_legal_process(id)
  status = formatted ? "✓" : "✗"
  puts "  #{status} #{id} => #{formatted}"
end
puts

# Invalid formatting examples
puts "Invalid formatting attempts:"
invalid_ids = ['123', '12345678901234567890123', 'abcd567890123456789', '']

invalid_ids.each do |id|
  formatted = BrazilianUtils::LegalProcessUtils.format_legal_process(id)
  display = id.empty? ? '(empty)' : id
  puts "  ✗ #{display} => #{formatted.inspect}"
end
puts

# ============================================================================
# Validating Legal Process IDs
# ============================================================================
puts "3. VALIDATING LEGAL PROCESS IDs"
puts "-" * 80

# Valid IDs (known from Python implementation)
valid_ids = [
  '68476506020233030000',
  '51808233620233030000',
  '6847650-60.2023.3.03.0000',
  '5180823-36.2023.3.03.0000'
]

puts "Validating known valid IDs:"
valid_ids.each do |id|
  result = BrazilianUtils::LegalProcessUtils.valid?(id)
  status = result ? "✓ VALID" : "✗ INVALID"
  puts "  #{status}: #{id}"
end
puts

# Invalid IDs
puts "Validating invalid IDs:"
invalid_ids = [
  ['123', 'wrong length'],
  ['12345678901234567890', 'invalid checksum'],
  ['1234567-89.2023.0.01.0000', 'invalid órgão (0)'],
  ['', 'empty string']
]

invalid_ids.each do |id, reason|
  result = BrazilianUtils::LegalProcessUtils.valid?(id)
  status = result ? "✓ VALID" : "✗ INVALID"
  display = id.empty? ? '(empty)' : id
  puts "  #{status}: #{display.ljust(30)} (#{reason})"
end
puts

# ============================================================================
# Generating Legal Process IDs
# ============================================================================
puts "4. GENERATING LEGAL PROCESS IDs"
puts "-" * 80

# Generate with current year and random órgão
puts "Generate with defaults (current year, random órgão):"
3.times do |i|
  id = BrazilianUtils::LegalProcessUtils.generate
  formatted = BrazilianUtils::LegalProcessUtils.format_legal_process(id)
  puts "  #{i + 1}. #{formatted}"
end
puts

# Generate with specific year
puts "Generate with year 2026:"
3.times do |i|
  id = BrazilianUtils::LegalProcessUtils.generate(2026)
  formatted = BrazilianUtils::LegalProcessUtils.format_legal_process(id)
  puts "  #{i + 1}. #{formatted}"
end
puts

# Generate for specific órgãos
puts "Generate for specific órgãos:"
orgaos = {
  1 => 'STF',
  3 => 'Justiça Militar',
  5 => 'Justiça do Trabalho',
  6 => 'Justiça Federal',
  8 => 'Justiça Estadual'
}

orgaos.each do |orgao, name|
  id = BrazilianUtils::LegalProcessUtils.generate(2026, orgao)
  formatted = BrazilianUtils::LegalProcessUtils.format_legal_process(id)
  puts "  Órgão #{orgao} (#{name}): #{formatted}"
end
puts

# Invalid generation attempts
puts "Invalid generation attempts:"
invalid_generations = [
  [2022, 5, 'year in the past'],
  [2026, 0, 'órgão 0 (invalid)'],
  [2026, 10, 'órgão 10 (out of range)']
]

invalid_generations.each do |year, orgao, reason|
  result = BrazilianUtils::LegalProcessUtils.generate(year, orgao)
  puts "  ✗ generate(#{year}, #{orgao}) => #{result.inspect} (#{reason})"
end
puts

# ============================================================================
# Validation After Generation
# ============================================================================
puts "5. VALIDATING GENERATED IDs"
puts "-" * 80

puts "Generating and validating 10 random IDs:"
10.times do |i|
  id = BrazilianUtils::LegalProcessUtils.generate(2026, rand(1..9))
  is_valid = BrazilianUtils::LegalProcessUtils.valid?(id)
  status = is_valid ? "✓" : "✗"
  formatted = BrazilianUtils::LegalProcessUtils.format_legal_process(id)
  puts "  #{status} #{i + 1}. #{formatted}"
end
puts

# ============================================================================
# Complete Workflow Example
# ============================================================================
puts "6. COMPLETE WORKFLOW: GENERATE → FORMAT → VALIDATE"
puts "-" * 80

process_id = BrazilianUtils::LegalProcessUtils.generate(2026, 5)
puts "Step 1 - Generate ID: #{process_id}"

formatted = BrazilianUtils::LegalProcessUtils.format_legal_process(process_id)
puts "Step 2 - Format ID:   #{formatted}"

is_valid = BrazilianUtils::LegalProcessUtils.valid?(process_id)
puts "Step 3 - Validate:    #{is_valid ? '✓ Valid' : '✗ Invalid'}"

# Extract information
parts = formatted.split(/[-.]/)
puts
puts "Extracted Information:"
puts "  Sequential Number: #{parts[0]}"
puts "  Checksum:          #{parts[1]}"
puts "  Year:              #{parts[2]}"
puts "  Órgão:             #{parts[3]}"
puts "  Tribunal:          #{parts[4]}"
puts "  Foro:              #{parts[5]}"
puts

# ============================================================================
# Real-World Use Case: Form Validation
# ============================================================================
puts "7. REAL-WORLD USE CASE: FORM VALIDATION"
puts "-" * 80

def validate_legal_process_form(process_id, description)
  errors = []
  
  errors << "Process ID is required" if process_id.nil? || process_id.empty?
  errors << "Description is required" if description.nil? || description.empty?
  
  if process_id && !process_id.empty?
    unless BrazilianUtils::LegalProcessUtils.valid?(process_id)
      errors << "Invalid legal process ID format"
    end
  end
  
  if errors.empty?
    clean_id = BrazilianUtils::LegalProcessUtils.remove_symbols(process_id)
    formatted_id = BrazilianUtils::LegalProcessUtils.format_legal_process(clean_id)
    {
      valid: true,
      message: "Form is valid",
      clean_id: clean_id,
      formatted_id: formatted_id
    }
  else
    { valid: false, errors: errors }
  end
end

test_forms = [
  { id: '6847650-60.2023.3.03.0000', desc: 'Military Court Case' },
  { id: '51808233620233030000', desc: 'Another Case' },
  { id: '12345678901234567890', desc: 'Invalid ID' },
  { id: '', desc: 'Empty ID Case' }
]

test_forms.each_with_index do |form, index|
  puts "\nTest Form #{index + 1}:"
  puts "  Process ID: #{form[:id].inspect}"
  puts "  Description: #{form[:desc]}"
  
  result = validate_legal_process_form(form[:id], form[:desc])
  
  if result[:valid]
    puts "  Status: ✓ #{result[:message]}"
    puts "  Clean ID: #{result[:clean_id]}"
    puts "  Formatted: #{result[:formatted_id]}"
  else
    puts "  Status: ✗ Validation failed"
    result[:errors].each do |error|
      puts "    - #{error}"
    end
  end
end
puts

# ============================================================================
# Batch Processing
# ============================================================================
puts "8. BATCH PROCESSING"
puts "-" * 80

legal_processes = [
  '68476506020233030000',
  '51808233620233030000',
  '12345678901234567890',
  '6847650-60.2023.3.03.0000',
  '123',
  'invalid'
]

valid_count = 0
invalid_count = 0

puts "Processing #{legal_processes.length} legal process IDs:"
legal_processes.each do |id|
  is_valid = BrazilianUtils::LegalProcessUtils.valid?(id)
  
  if is_valid
    valid_count += 1
    formatted = BrazilianUtils::LegalProcessUtils.format_legal_process(
      BrazilianUtils::LegalProcessUtils.remove_symbols(id)
    )
    puts "  ✓ #{formatted}"
  else
    invalid_count += 1
    puts "  ✗ #{id.inspect} (invalid)"
  end
end

puts
puts "Summary:"
puts "  Total:   #{legal_processes.length}"
puts "  Valid:   #{valid_count} (#{(valid_count * 100.0 / legal_processes.length).round(1)}%)"
puts "  Invalid: #{invalid_count} (#{(invalid_count * 100.0 / legal_processes.length).round(1)}%)"
puts

# ============================================================================
# Format Conversion
# ============================================================================
puts "9. FORMAT CONVERSION: FORMATTED ↔ CLEAN"
puts "-" * 80

conversion_examples = [
  '6847650-60.2023.3.03.0000',
  '5180823-36.2023.3.03.0000'
]

puts "Converting between formatted and clean formats:"
conversion_examples.each do |formatted|
  puts "\nOriginal (formatted): #{formatted}"
  
  # Convert to clean
  clean = BrazilianUtils::LegalProcessUtils.remove_symbols(formatted)
  puts "  → Clean:   #{clean}"
  
  # Convert back to formatted
  reformatted = BrazilianUtils::LegalProcessUtils.format_legal_process(clean)
  puts "  → Format:  #{reformatted}"
  
  # Verify both formats are valid
  valid_formatted = BrazilianUtils::LegalProcessUtils.valid?(formatted)
  valid_clean = BrazilianUtils::LegalProcessUtils.valid?(clean)
  puts "  → Both formats valid: #{valid_formatted && valid_clean}"
end
puts

# ============================================================================
# Generate IDs for All Órgãos
# ============================================================================
puts "10. GENERATE IDs FOR ALL ÓRGÃOS"
puts "-" * 80

all_orgaos = {
  1 => 'Supremo Tribunal Federal (STF)',
  2 => 'Conselho Nacional de Justiça (CNJ)',
  3 => 'Justiça Militar',
  4 => 'Justiça Eleitoral',
  5 => 'Justiça do Trabalho',
  6 => 'Justiça Federal',
  7 => 'Justiça Estadual',
  8 => 'Justiça dos Estados e DF',
  9 => 'Justiça Militar Estadual'
}

puts "Generating one ID for each órgão:"
all_orgaos.each do |orgao, name|
  id = BrazilianUtils::LegalProcessUtils.generate(2026, orgao)
  formatted = BrazilianUtils::LegalProcessUtils.format_legal_process(id)
  is_valid = BrazilianUtils::LegalProcessUtils.valid?(id)
  status = is_valid ? "✓" : "✗"
  puts "  #{status} Órgão #{orgao}: #{formatted}"
  puts "     #{name}"
end
puts

# ============================================================================
# Database Storage Example
# ============================================================================
puts "11. DATABASE STORAGE EXAMPLE"
puts "-" * 80

puts "Simulating database operations:"
puts

# User submits a formatted ID
user_input = '6847650-60.2023.3.03.0000'
puts "User input: #{user_input}"

# Validate
if BrazilianUtils::LegalProcessUtils.valid?(user_input)
  # Clean for storage (remove formatting)
  db_format = BrazilianUtils::LegalProcessUtils.remove_symbols(user_input)
  puts "✓ Valid! Storing in database: #{db_format}"
  
  # Later, retrieve and format for display
  puts "Retrieved from database: #{db_format}"
  display_format = BrazilianUtils::LegalProcessUtils.format_legal_process(db_format)
  puts "Formatted for display: #{display_format}"
else
  puts "✗ Invalid legal process ID - rejecting input"
end
puts

# ============================================================================
# Statistics
# ============================================================================
puts "12. GENERATION STATISTICS"
puts "-" * 80

puts "Generating 100 random legal process IDs and analyzing..."

generated_ids = 100.times.map do
  BrazilianUtils::LegalProcessUtils.generate(2026, rand(1..9))
end

# Count by órgão
orgao_counts = Hash.new(0)
generated_ids.each do |id|
  orgao = id[13, 1].to_i
  orgao_counts[orgao] += 1
end

puts "Distribution by Órgão:"
orgao_counts.sort.each do |orgao, count|
  percentage = (count * 100.0 / generated_ids.length).round(1)
  bar = '█' * (count / 2)
  puts "  Órgão #{orgao}: #{count.to_s.rjust(3)} (#{percentage.to_s.rjust(5)}%) #{bar}"
end

# Verify all are valid
all_valid = generated_ids.all? { |id| BrazilianUtils::LegalProcessUtils.valid?(id) }
puts "\nAll generated IDs are valid: #{all_valid ? '✓ Yes' : '✗ No'}"
puts

puts "=" * 80
puts "Examples completed!"
puts "=" * 80
