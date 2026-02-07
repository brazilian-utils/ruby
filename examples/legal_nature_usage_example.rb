require_relative '../lib/brazilian-utils/legal-nature-utils'

puts "=" * 80
puts "Brazilian Legal Nature Utils - Usage Examples"
puts "=" * 80
puts

# ============================================================================
# Code Validation
# ============================================================================
puts "1. CODE VALIDATION"
puts "-" * 80

valid_codes = [
  '2062',  # Sociedade Empresária Limitada
  '1015',  # Órgão Público Federal
  '2305',  # EIRELI
  '3123',  # Partido Político
  '2046',  # S.A. Aberta
  '2054',  # S.A. Fechada
  '4014',  # Empresa Individual Imobiliária
  '5002'   # Organização Internacional
]

puts "Valid Legal Nature Codes:"
valid_codes.each do |code|
  result = BrazilianUtils::LegalNatureUtils.is_valid(code)
  status = result ? "✓" : "✗"
  puts "  #{status} #{code} - #{BrazilianUtils::LegalNatureUtils.get_description(code)}"
end
puts

# ============================================================================
# Code Validation with Hyphen Format
# ============================================================================
puts "2. CODE VALIDATION WITH HYPHEN FORMAT"
puts "-" * 80

codes_with_hyphen = [
  ['2062', '206-2'],
  ['1015', '101-5'],
  ['2305', '230-5'],
  ['3123', '312-3']
]

puts "Comparing formats (without and with hyphen):"
codes_with_hyphen.each do |without, with_hyphen|
  result1 = BrazilianUtils::LegalNatureUtils.is_valid(without)
  result2 = BrazilianUtils::LegalNatureUtils.is_valid(with_hyphen)
  status = (result1 && result2) ? "✓" : "✗"
  puts "  #{status} #{without} and #{with_hyphen}: Both valid = #{result1 && result2}"
end
puts

# ============================================================================
# Invalid Codes
# ============================================================================
puts "3. INVALID CODES"
puts "-" * 80

invalid_codes = [
  '9999',      # Not in table
  '0000',      # Not in table
  '1234',      # Not in table
  '123',       # Wrong length
  'abcd',      # Not digits
  '',          # Empty
  'invalid'    # Invalid format
]

puts "Invalid codes:"
invalid_codes.each do |code|
  result = BrazilianUtils::LegalNatureUtils.is_valid(code)
  status = result ? "✓" : "✗"
  display = code.empty? ? '(empty)' : code
  puts "  #{status} #{display.ljust(10)} - Valid: #{result}"
end
puts

# ============================================================================
# Description Lookup
# ============================================================================
puts "4. DESCRIPTION LOOKUP"
puts "-" * 80

lookup_codes = {
  '2062' => 'Limited Liability Company',
  '1015' => 'Federal Public Agency',
  '2305' => 'Individual Limited Liability Company',
  '3123' => 'Political Party',
  '2046' => 'Open Corporation',
  '2143' => 'Cooperative',
  '3050' => 'OSCIP'
}

puts "Code descriptions:"
lookup_codes.each do |code, english_name|
  description = BrazilianUtils::LegalNatureUtils.get_description(code)
  puts "  #{code}: #{description}"
  puts "         (#{english_name})"
end
puts

# ============================================================================
# List All Codes
# ============================================================================
puts "5. LIST ALL CODES"
puts "-" * 80

all_codes = BrazilianUtils::LegalNatureUtils.list_all
puts "Total legal nature codes in official table: #{all_codes.size}"
puts
puts "Sample of all codes (first 10):"
all_codes.first(10).each do |code, description|
  puts "  #{code}: #{description}"
end
puts "  ... (#{all_codes.size - 10} more codes)"
puts

# ============================================================================
# List by Category
# ============================================================================
puts "6. LIST BY CATEGORY"
puts "-" * 80

categories = {
  1 => 'Administração Pública (Public Administration)',
  2 => 'Entidades Empresariais (Business Entities)',
  3 => 'Entidades Sem Fins Lucrativos (Non-Profit Entities)',
  4 => 'Pessoas Físicas (Individuals)',
  5 => 'Organizações Internacionais (International Organizations)'
}

categories.each do |category_num, category_name|
  codes = BrazilianUtils::LegalNatureUtils.list_by_category(category_num)
  puts "Category #{category_num}: #{category_name}"
  puts "  Total codes: #{codes.size}"
  puts "  Sample codes:"
  codes.first(3).each do |code, description|
    puts "    #{code}: #{description}"
  end
  puts
end

# ============================================================================
# Get Category
# ============================================================================
puts "7. GET CATEGORY"
puts "-" * 80

test_codes = ['2062', '1015', '3123', '4014', '5002', '206-2', '9999']

puts "Code categories:"
test_codes.each do |code|
  category = BrazilianUtils::LegalNatureUtils.get_category(code)
  if category
    category_name = categories[category]
    puts "  #{code}: Category #{category} - #{category_name}"
  else
    puts "  #{code}: Invalid code (no category)"
  end
end
puts

# ============================================================================
# Category 2: Business Entities (Most Common)
# ============================================================================
puts "8. CATEGORY 2: BUSINESS ENTITIES (MOST COMMON)"
puts "-" * 80

business_entities = BrazilianUtils::LegalNatureUtils.list_by_category(2)
puts "All Business Entity Types (#{business_entities.size} codes):"
business_entities.each do |code, description|
  puts "  #{code}: #{description}"
end
puts

# ============================================================================
# Searching for Specific Types
# ============================================================================
puts "9. SEARCHING FOR SPECIFIC TYPES"
puts "-" * 80

# Search for cooperatives
puts "Searching for 'Cooperativa':"
all_codes.select { |_, desc| desc.downcase.include?('cooperativa') }.each do |code, description|
  puts "  #{code}: #{description}"
end
puts

# Search for political parties
puts "Searching for 'Partido':"
all_codes.select { |_, desc| desc.downcase.include?('partido') }.each do |code, description|
  puts "  #{code}: #{description}"
end
puts

# Search for foundations
puts "Searching for 'Fundação':"
all_codes.select { |_, desc| desc.downcase.include?('fundação') }.each do |code, description|
  puts "  #{code}: #{description}"
end
puts

# ============================================================================
# Practical Use Case: Company Registration
# ============================================================================
puts "10. PRACTICAL USE CASE: COMPANY REGISTRATION"
puts "-" * 80

def validate_company_registration(name, cnpj, legal_nature_code)
  errors = []
  
  errors << "Company name is required" if name.nil? || name.empty?
  errors << "CNPJ is required" if cnpj.nil? || cnpj.empty?
  errors << "Legal nature code is required" if legal_nature_code.nil? || legal_nature_code.empty?
  
  if legal_nature_code && !legal_nature_code.empty?
    unless BrazilianUtils::LegalNatureUtils.valid?(legal_nature_code)
      errors << "Invalid legal nature code: #{legal_nature_code}"
    end
  end
  
  if errors.empty?
    description = BrazilianUtils::LegalNatureUtils.get_description(legal_nature_code)
    category = BrazilianUtils::LegalNatureUtils.get_category(legal_nature_code)
    {
      valid: true,
      message: "Registration is valid",
      legal_nature: description,
      category: category
    }
  else
    { valid: false, errors: errors }
  end
end

test_registrations = [
  { name: 'Tech Company LTDA', cnpj: '12.345.678/0001-90', code: '2062' },
  { name: 'Open Corporation SA', cnpj: '98.765.432/0001-10', code: '2046' },
  { name: 'Invalid Corp', cnpj: '11.111.111/0001-11', code: '9999' },
  { name: '', cnpj: '12.345.678/0001-90', code: '2062' }
]

test_registrations.each_with_index do |reg, index|
  puts "\nTest Registration #{index + 1}:"
  puts "  Name: #{reg[:name].inspect}"
  puts "  CNPJ: #{reg[:cnpj]}"
  puts "  Legal Nature Code: #{reg[:code]}"
  
  result = validate_company_registration(reg[:name], reg[:cnpj], reg[:code])
  
  if result[:valid]
    puts "  Status: ✓ #{result[:message]}"
    puts "  Legal Nature: #{result[:legal_nature]}"
    puts "  Category: #{result[:category]}"
  else
    puts "  Status: ✗ Validation failed"
    result[:errors].each do |error|
      puts "    - #{error}"
    end
  end
end
puts

# ============================================================================
# Statistics by Category
# ============================================================================
puts "11. STATISTICS BY CATEGORY"
puts "-" * 80

puts "Legal Nature Codes Distribution:"
(1..5).each do |cat|
  codes = BrazilianUtils::LegalNatureUtils.list_by_category(cat)
  category_name = categories[cat].split(' (').first
  percentage = (codes.size * 100.0 / all_codes.size).round(1)
  puts "  Category #{cat}: #{codes.size.to_s.rjust(2)} codes (#{percentage.to_s.rjust(4)}%) - #{category_name}"
end
puts "  Total:       #{all_codes.size} codes"
puts

# ============================================================================
# Common Company Types
# ============================================================================
puts "12. COMMON COMPANY TYPES IN BRAZIL"
puts "-" * 80

common_types = [
  '2062',  # LTDA
  '2305',  # EIRELI
  '2135',  # Empresário Individual
  '2046',  # S.A. Aberta
  '2054',  # S.A. Fechada
  '2143'   # Cooperativa
]

puts "Most common legal nature codes for companies:"
common_types.each do |code|
  description = BrazilianUtils::LegalNatureUtils.get_description(code)
  puts "  #{code}: #{description}"
  
  # Show English equivalent
  case code
  when '2062'
    puts "         (Similar to: LLC - Limited Liability Company)"
  when '2305'
    puts "         (Similar to: Single-member LLC)"
  when '2135'
    puts "         (Similar to: Sole Proprietorship)"
  when '2046'
    puts "         (Similar to: Public Corporation)"
  when '2054'
    puts "         (Similar to: Private Corporation)"
  when '2143'
    puts "         (Similar to: Cooperative)"
  end
end
puts

# ============================================================================
# Validation with Feedback
# ============================================================================
puts "13. VALIDATION WITH DETAILED FEEDBACK"
puts "-" * 80

def validate_with_feedback(code)
  unless BrazilianUtils::LegalNatureUtils.valid?(code)
    if code.nil? || code.empty?
      return { valid: false, message: "Code cannot be empty" }
    elsif code.gsub(/\D/, '').length != 4
      return { valid: false, message: "Code must have exactly 4 digits" }
    else
      return { valid: false, message: "Code not found in official RFB table" }
    end
  end
  
  description = BrazilianUtils::LegalNatureUtils.get_description(code)
  category = BrazilianUtils::LegalNatureUtils.get_category(code)
  category_name = categories[category]
  
  {
    valid: true,
    message: "Code is valid",
    code: code.gsub(/\D/, ''),
    description: description,
    category: category,
    category_name: category_name
  }
end

test_codes_feedback = ['2062', '206-2', '9999', '123', '', 'invalid', '1015']

test_codes_feedback.each do |code|
  result = validate_with_feedback(code)
  display = code.empty? ? '(empty)' : code
  
  if result[:valid]
    puts "✓ #{display.ljust(10)} - #{result[:description]}"
    puts "  #{' ' * 10}   Category #{result[:category]}: #{result[:category_name]}"
  else
    puts "✗ #{display.ljust(10)} - #{result[:message]}"
  end
end
puts

# ============================================================================
# Batch Validation
# ============================================================================
puts "14. BATCH VALIDATION"
puts "-" * 80

batch_codes = ['2062', '1015', '9999', '2305', '0000', '3123', 'invalid', '2046']

valid_count = 0
invalid_count = 0

puts "Validating #{batch_codes.size} codes:"
batch_codes.each do |code|
  result = BrazilianUtils::LegalNatureUtils.valid?(code)
  status = result ? "✓" : "✗"
  
  if result
    valid_count += 1
    desc = BrazilianUtils::LegalNatureUtils.get_description(code)
    puts "  #{status} #{code.ljust(10)} - #{desc}"
  else
    invalid_count += 1
    puts "  #{status} #{code.ljust(10)} - Invalid"
  end
end

puts
puts "Summary:"
puts "  Valid:   #{valid_count} (#{(valid_count * 100.0 / batch_codes.size).round(1)}%)"
puts "  Invalid: #{invalid_count} (#{(invalid_count * 100.0 / batch_codes.size).round(1)}%)"
puts

# ============================================================================
# Complete Workflow Example
# ============================================================================
puts "15. COMPLETE WORKFLOW EXAMPLE"
puts "-" * 80

company_code = '2062'

puts "Analyzing legal nature code: #{company_code}"
puts

# Step 1: Validate
if BrazilianUtils::LegalNatureUtils.valid?(company_code)
  puts "✓ Code is valid"
  
  # Step 2: Get description
  description = BrazilianUtils::LegalNatureUtils.get_description(company_code)
  puts "  Description: #{description}"
  
  # Step 3: Get category
  category = BrazilianUtils::LegalNatureUtils.get_category(company_code)
  category_name = categories[category]
  puts "  Category: #{category} - #{category_name}"
  
  # Step 4: List similar codes in the same category
  similar_codes = BrazilianUtils::LegalNatureUtils.list_by_category(category)
  puts "  Similar legal natures in this category: #{similar_codes.size} codes"
  puts "  Examples:"
  similar_codes.first(5).each do |code, desc|
    marker = code == company_code ? " ← (current)" : ""
    puts "    - #{code}: #{desc}#{marker}"
  end
else
  puts "✗ Code is invalid"
end

puts
puts "=" * 80
puts "Examples completed!"
puts "=" * 80
