# frozen_string_literal: true

require_relative '../lib/brazilian-utils/boleto-utils'

# Examples of using BoletoUtils module

puts '=' * 80
puts 'Boleto Utils - Usage Examples'
puts '=' * 80
puts

# Example 1: Validating a correct boleto digitable line
puts '1. Validating a correct boleto digitable line (47 digits):'
valid_boleto = '00190000090114971860168524522114675860000102656'
puts "   Boleto: #{valid_boleto}"
puts "   Is valid? #{BrazilianUtils::BoletoUtils.is_valid(valid_boleto)}"
puts

# Example 2: Validating a formatted boleto digitable line (with spaces and dots)
puts '2. Validating a formatted boleto digitable line:'
formatted_boleto = '0019000009 01149.718601 68524.522114 6 75860000102656'
puts "   Boleto: #{formatted_boleto}"
puts "   Is valid? #{BrazilianUtils::BoletoUtils.is_valid(formatted_boleto)}"
puts

# Example 3: Validating an invalid boleto (wrong first partial check digit)
puts '3. Validating an invalid boleto (wrong first partial check digit):'
invalid_boleto_1 = '00190000020114971860168524522114675860000102656'
puts "   Boleto: #{invalid_boleto_1}"
puts "   Is valid? #{BrazilianUtils::BoletoUtils.is_valid(invalid_boleto_1)}"
puts

# Example 4: Validating an invalid boleto (wrong mod11 check digit)
puts '4. Validating an invalid boleto (wrong mod11 check digit):'
invalid_boleto_2 = '00190000090114971860168524522114975860000102656'
puts "   Boleto: #{invalid_boleto_2}"
puts "   Is valid? #{BrazilianUtils::BoletoUtils.is_valid(invalid_boleto_2)}"
puts

# Example 5: Validating with empty string
puts '5. Validating with empty string:'
puts "   Boleto: ''"
puts "   Is valid? #{BrazilianUtils::BoletoUtils.is_valid('')}"
puts

# Example 6: Validating with insufficient length
puts '6. Validating with insufficient length:'
short_boleto = '000111'
puts "   Boleto: #{short_boleto}"
puts "   Is valid? #{BrazilianUtils::BoletoUtils.is_valid(short_boleto)}"
puts

# Example 7: Using the alias method 'valid?'
puts '7. Using the alias method `valid?`:'
puts "   Boleto: #{valid_boleto}"
puts "   Is valid? #{BrazilianUtils::BoletoUtils.valid?(valid_boleto)}"
puts

# Example 8: Validating boleto with various formatting
puts '8. Validating boleto with dots in different positions:'
formatted_with_dots = '00190.00009 01149.718601 68524.522114 6 75860000102656'
puts "   Boleto: #{formatted_with_dots}"
puts "   Is valid? #{BrazilianUtils::BoletoUtils.is_valid(formatted_with_dots)}"
puts

puts '=' * 80
puts 'What is a Boleto Digitable Line?'
puts '=' * 80
puts
puts 'A boleto digitable line (linha digitável) is a 47-digit number that represents'
puts 'a Brazilian payment slip (boleto bancário). It contains:'
puts '  - Bank code'
puts '  - Currency code'
puts '  - Check digits (mod10 for partials, mod11 for general validation)'
puts '  - Amount and due date information'
puts
puts 'The digitable line is typically formatted with spaces and dots for readability,'
puts 'but the validation works with the numeric-only version.'
puts '=' * 80
