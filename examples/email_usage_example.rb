require_relative '../lib/brazilian-utils/email-utils'

puts "=" * 70
puts "Brazilian Email Utils - Usage Examples"
puts "=" * 70
puts

# ============================================================================
# Valid Email Addresses
# ============================================================================
puts "1. VALID EMAIL ADDRESSES"
puts "-" * 70

valid_emails = [
  'brutils@brutils.com',
  'user.name@example.com',
  'user+tag@example.co.uk',
  'user_123@test-domain.com',
  'contact@company.com.br',
  'john.doe@gmail.com',
  'jane.smith@outlook.com',
  'first.middle.last@example.com',
  'employee@mail.example.com',
  'user2024@example.com',
  'User.Name@Example.COM'
]

valid_emails.each do |email|
  result = BrazilianUtils::EmailUtils.is_valid(email)
  status = result ? "✓ VALID" : "✗ INVALID"
  puts "#{status.ljust(10)} #{email}"
end
puts

# ============================================================================
# Invalid Email Addresses
# ============================================================================
puts "2. INVALID EMAIL ADDRESSES"
puts "-" * 70

invalid_emails = [
  'invalid-email@brutils',        # No TLD
  '.user@example.com',             # Starts with dot
  'user@',                         # No domain
  '@example.com',                  # No local part
  'user name@example.com',         # Contains space
  'user@example.c',                # TLD too short
  'user@@example.com',             # Double @
  'user..name@example.com',        # Consecutive dots
  'userexample.com',               # No @ symbol
  'user@examplecom',               # No dot in domain
  'user[name]@example.com',        # Invalid characters
  '',                              # Empty string
  ' user@example.com',             # Leading space
  'user@example.com '              # Trailing space
]

invalid_emails.each do |email|
  result = BrazilianUtils::EmailUtils.is_valid(email)
  status = result ? "✓ VALID" : "✗ INVALID"
  display_email = email.empty? ? '(empty string)' : email.inspect
  puts "#{status.ljust(10)} #{display_email}"
end
puts

# ============================================================================
# Using the valid? Alias
# ============================================================================
puts "3. USING THE valid? ALIAS"
puts "-" * 70

test_email = 'user@example.com'
puts "BrazilianUtils::EmailUtils.is_valid('#{test_email}'): #{BrazilianUtils::EmailUtils.is_valid(test_email)}"
puts "BrazilianUtils::EmailUtils.valid?('#{test_email}'): #{BrazilianUtils::EmailUtils.valid?(test_email)}"
puts

# ============================================================================
# Non-String Inputs
# ============================================================================
puts "4. NON-STRING INPUTS"
puts "-" * 70

non_string_inputs = [
  [nil, 'nil'],
  [123, 'Integer (123)'],
  [12.34, 'Float (12.34)'],
  [true, 'Boolean (true)'],
  [['user@example.com'], 'Array'],
  [{ email: 'user@example.com' }, 'Hash'],
  [:email, 'Symbol']
]

non_string_inputs.each do |value, description|
  result = BrazilianUtils::EmailUtils.is_valid(value)
  status = result ? "✓ VALID" : "✗ INVALID"
  puts "#{status.ljust(10)} #{description}"
end
puts

# ============================================================================
# Practical Use Case: Form Validation
# ============================================================================
puts "5. PRACTICAL USE CASE: FORM VALIDATION"
puts "-" * 70

def validate_contact_form(name, email, message)
  errors = []
  
  errors << "Name is required" if name.nil? || name.empty?
  errors << "Email is required" if email.nil? || email.empty?
  errors << "Invalid email format" unless BrazilianUtils::EmailUtils.valid?(email)
  errors << "Message is required" if message.nil? || message.empty?
  
  if errors.empty?
    { valid: true, message: "Form is valid" }
  else
    { valid: false, errors: errors }
  end
end

# Test cases
test_forms = [
  { name: 'João Silva', email: 'joao@example.com', message: 'Hello!' },
  { name: 'Maria Santos', email: 'invalid-email', message: 'Hi!' },
  { name: '', email: 'maria@example.com', message: 'Test' },
  { name: 'Pedro Costa', email: 'pedro@company.com.br', message: '' },
  { name: 'Ana Lima', email: '', message: 'Message' }
]

test_forms.each_with_index do |form, index|
  puts "\nTest #{index + 1}:"
  puts "  Name: #{form[:name].inspect}"
  puts "  Email: #{form[:email].inspect}"
  puts "  Message: #{form[:message].inspect}"
  
  result = validate_contact_form(form[:name], form[:email], form[:message])
  
  if result[:valid]
    puts "  Result: ✓ #{result[:message]}"
  else
    puts "  Result: ✗ Errors:"
    result[:errors].each do |error|
      puts "    - #{error}"
    end
  end
end
puts

# ============================================================================
# Batch Email Validation
# ============================================================================
puts "6. BATCH EMAIL VALIDATION"
puts "-" * 70

email_list = [
  'john.doe@gmail.com',
  'invalid@domain',
  'jane+newsletter@example.com',
  '@incomplete.com',
  'corporate@company.com.br',
  'user..name@example.com',
  'contact@subdomain.example.com',
  'user@example.c',
  'valid.email_123+tag@test-server.co.uk'
]

valid_emails = []
invalid_emails = []

email_list.each do |email|
  if BrazilianUtils::EmailUtils.valid?(email)
    valid_emails << email
  else
    invalid_emails << email
  end
end

puts "Total emails: #{email_list.length}"
puts "Valid emails: #{valid_emails.length}"
puts "Invalid emails: #{invalid_emails.length}"
puts
puts "Valid emails:"
valid_emails.each { |email| puts "  ✓ #{email}" }
puts
puts "Invalid emails:"
invalid_emails.each { |email| puts "  ✗ #{email}" }
puts

# ============================================================================
# Real-World Email Examples
# ============================================================================
puts "7. REAL-WORLD EMAIL EXAMPLES"
puts "-" * 70

real_world_examples = {
  'Gmail' => 'john.doe+spam@gmail.com',
  'Outlook' => 'jane.smith@outlook.com',
  'Corporate' => 'employee@company.com',
  'Brazilian domain' => 'contato@empresa.com.br',
  'Subdomain' => 'support@help.example.com',
  'Government' => 'contato@governo.gov.br',
  'University' => 'aluno@universidade.edu.br',
  'With numbers' => 'user2024@example.com',
  'With underscores' => 'first_last@example.com',
  'Multiple dots' => 'first.middle.last@example.com'
}

real_world_examples.each do |category, email|
  result = BrazilianUtils::EmailUtils.valid?(email)
  status = result ? "✓" : "✗"
  puts "#{status} #{category.ljust(18)}: #{email}"
end
puts

# ============================================================================
# Email Validation with Feedback
# ============================================================================
puts "8. EMAIL VALIDATION WITH DETAILED FEEDBACK"
puts "-" * 70

def validate_email_with_feedback(email)
  unless email.is_a?(String)
    return { valid: false, message: "Email must be a string, got #{email.class}" }
  end
  
  if email.empty?
    return { valid: false, message: "Email cannot be empty" }
  end
  
  unless email.include?('@')
    return { valid: false, message: "Email must contain @ symbol" }
  end
  
  if email.start_with?('.')
    return { valid: false, message: "Email cannot start with a dot" }
  end
  
  unless email.match?(/\.[a-zA-Z]{2,}$/)
    return { valid: false, message: "Email must have a valid TLD (at least 2 letters)" }
  end
  
  if BrazilianUtils::EmailUtils.valid?(email)
    { valid: true, message: "Email is valid" }
  else
    { valid: false, message: "Email format is invalid" }
  end
end

test_emails_feedback = [
  'valid@example.com',
  'invalid',
  '@domain.com',
  '.user@example.com',
  'user@domain',
  nil,
  ''
]

test_emails_feedback.each do |email|
  result = validate_email_with_feedback(email)
  status = result[:valid] ? "✓ VALID" : "✗ INVALID"
  display = email.nil? ? 'nil' : (email.empty? ? '(empty)' : email)
  puts "#{status.ljust(10)} #{display.ljust(25)} => #{result[:message]}"
end
puts

# ============================================================================
# Statistics
# ============================================================================
puts "9. EMAIL VALIDATION STATISTICS"
puts "-" * 70

all_test_emails = [
  'user@example.com', 'invalid@', '@example.com', 'user.name@example.com',
  'user+tag@example.co.uk', 'invalid email@test.com', 'user@domain',
  'test..user@example.com', 'user@test-domain.com', '.user@example.com',
  'user@example.c', 'john.doe@gmail.com', 'user@subdomain.example.com',
  'contact@company.com.br', 'user@example.com '
]

valid_count = all_test_emails.count { |email| BrazilianUtils::EmailUtils.valid?(email) }
invalid_count = all_test_emails.count { |email| !BrazilianUtils::EmailUtils.valid?(email) }

puts "Total emails tested: #{all_test_emails.length}"
puts "Valid: #{valid_count} (#{(valid_count * 100.0 / all_test_emails.length).round(1)}%)"
puts "Invalid: #{invalid_count} (#{(invalid_count * 100.0 / all_test_emails.length).round(1)}%)"
puts

# ============================================================================
# Common Mistakes
# ============================================================================
puts "10. COMMON EMAIL MISTAKES"
puts "-" * 70

common_mistakes = {
  'Missing @' => 'userexample.com',
  'Missing domain' => 'user@',
  'Missing local part' => '@example.com',
  'Space in email' => 'user name@example.com',
  'No TLD' => 'user@domain',
  'TLD too short' => 'user@example.c',
  'Starts with dot' => '.user@example.com',
  'Consecutive dots' => 'user..name@example.com',
  'Double @' => 'user@@example.com',
  'Special chars' => 'user!name@example.com',
  'Trailing space' => 'user@example.com ',
  'Leading space' => ' user@example.com'
}

puts "Mistake                    Email                          Valid?"
puts "-" * 70
common_mistakes.each do |mistake, email|
  result = BrazilianUtils::EmailUtils.valid?(email)
  status = result ? "Yes" : "No"
  puts "#{mistake.ljust(26)} #{email.inspect.ljust(30)} #{status}"
end

puts
puts "=" * 70
puts "Examples completed!"
puts "=" * 70
