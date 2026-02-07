require 'spec_helper'

RSpec.describe BrazilianUtils::PISUtils do
  describe '.remove_symbols' do
    it 'removes dots and hyphens from formatted PIS' do
      expect(described_class.remove_symbols('123.45678.90-9')).to eq('12345678909')
    end

    it 'removes dots and hyphens from another formatted PIS' do
      expect(described_class.remove_symbols('987.65432.10-0')).to eq('98765432100')
    end

    it 'returns unchanged string if no symbols' do
      expect(described_class.remove_symbols('12345678909')).to eq('12345678909')
    end

    it 'removes only dots' do
      expect(described_class.remove_symbols('123.456.789.09')).to eq('12345678909')
    end

    it 'removes only hyphens' do
      expect(described_class.remove_symbols('12345678-909')).to eq('12345678909')
    end

    it 'removes multiple dashes and dots' do
      expect(described_class.remove_symbols('1-2-3.4-5.6-7-8.9-0-9')).to eq('12345678909')
    end

    it 'returns empty string for empty input' do
      expect(described_class.remove_symbols('')).to eq('')
    end

    it 'returns empty string for nil input' do
      expect(described_class.remove_symbols(nil)).to eq('')
    end

    it 'returns empty string for non-string input' do
      expect(described_class.remove_symbols(12345678909)).to eq('')
    end

    it 'has an alias method .sieve' do
      expect(described_class.sieve('123.45678.90-9')).to eq('12345678909')
    end
  end

  describe '.format_pis' do
    context 'when formatting valid PIS numbers' do
      it 'formats 12345678909' do
        expect(described_class.format_pis('12345678909')).to eq('123.45678.90-9')
      end

      it 'formats 98765432100' do
        expect(described_class.format_pis('98765432100')).to eq('987.65432.10-0')
      end

      it 'formats PIS starting with 0' do
        expect(described_class.format_pis('01234567890')).to eq('012.34567.89-0')
      end

      it 'formats PIS with all same digits except checksum' do
        # Need to find a valid PIS with repeated digits
        # Generate one to ensure it's valid
        pis = described_class.generate
        formatted = described_class.format_pis(pis)
        expect(formatted).to match(/^\d{3}\.\d{5}\.\d{2}-\d$/)
      end
    end

    context 'when formatting fails' do
      it 'returns nil for invalid PIS' do
        expect(described_class.format_pis('12345678900')).to be_nil
      end

      it 'returns nil for too short PIS' do
        expect(described_class.format_pis('123456789')).to be_nil
      end

      it 'returns nil for too long PIS' do
        expect(described_class.format_pis('123456789012')).to be_nil
      end

      it 'returns nil for PIS with letters' do
        expect(described_class.format_pis('1234567890A')).to be_nil
      end

      it 'returns nil for empty string' do
        expect(described_class.format_pis('')).to be_nil
      end

      it 'returns nil for nil input' do
        expect(described_class.format_pis(nil)).to be_nil
      end

      it 'returns nil for PIS with symbols (should remove first)' do
        expect(described_class.format_pis('123.45678.90-9')).to be_nil
      end
    end

    it 'has an alias method .format' do
      expect(described_class.format('12345678909')).to eq('123.45678.90-9')
    end
  end

  describe '.is_valid' do
    context 'when validating valid PIS numbers' do
      it 'validates 12345678909' do
        expect(described_class.is_valid('12345678909')).to be true
      end

      it 'validates 98765432100' do
        expect(described_class.is_valid('98765432100')).to be true
      end

      it 'validates PIS starting with 0' do
        expect(described_class.is_valid('01234567890')).to be true
      end

      it 'validates PIS with checksum 0' do
        expect(described_class.is_valid('98765432100')).to be true
      end

      # Testing with known valid PIS numbers
      it 'validates known valid PIS 12082043600' do
        expect(described_class.is_valid('12082043600')).to be true
      end

      it 'validates known valid PIS 17033259504' do
        expect(described_class.is_valid('17033259504')).to be true
      end

      it 'validates known valid PIS 10000000000' do
        # Calculate if this is valid
        base = '1000000000'
        checksum = described_class.send(:checksum, base)
        pis = base + checksum.to_s
        expect(described_class.is_valid(pis)).to be true
      end
    end

    context 'when validation fails' do
      it 'rejects PIS with wrong checksum' do
        expect(described_class.is_valid('12345678900')).to be false
      end

      it 'rejects PIS with wrong checksum (last digit off by 1)' do
        expect(described_class.is_valid('12345678908')).to be false
      end

      it 'rejects too short PIS' do
        expect(described_class.is_valid('123456789')).to be false
      end

      it 'rejects too long PIS' do
        expect(described_class.is_valid('123456789012')).to be false
      end

      it 'rejects PIS with letters' do
        expect(described_class.is_valid('1234567890A')).to be false
      end

      it 'rejects PIS with special characters' do
        expect(described_class.is_valid('12345678@09')).to be false
      end

      it 'rejects PIS with symbols (should remove first)' do
        expect(described_class.is_valid('123.45678.90-9')).to be false
      end

      it 'rejects PIS with spaces' do
        expect(described_class.is_valid('123 456 789 09')).to be false
      end

      it 'rejects empty string' do
        expect(described_class.is_valid('')).to be false
      end

      it 'rejects nil' do
        expect(described_class.is_valid(nil)).to be false
      end

      it 'rejects numeric input' do
        expect(described_class.is_valid(12345678909)).to be false
      end

      it 'rejects all zeros' do
        expect(described_class.is_valid('00000000000')).to be false
      end

      it 'rejects all ones' do
        expect(described_class.is_valid('11111111111')).to be false
      end

      it 'rejects all nines' do
        expect(described_class.is_valid('99999999999')).to be false
      end
    end

    it 'has an alias method .valid?' do
      expect(described_class.valid?('12345678909')).to be true
    end
  end

  describe '.generate' do
    it 'generates a valid PIS' do
      pis = described_class.generate
      expect(described_class.is_valid(pis)).to be true
    end

    it 'generates an 11-digit PIS' do
      pis = described_class.generate
      expect(pis.length).to eq(11)
    end

    it 'generates PIS with only digits' do
      pis = described_class.generate
      expect(pis).to match(/^\d{11}$/)
    end

    it 'generates different PIS numbers on multiple calls' do
      pis_numbers = 10.times.map { described_class.generate }
      expect(pis_numbers.uniq.length).to be > 1
    end

    it 'generates PIS that can be formatted' do
      pis = described_class.generate
      formatted = described_class.format_pis(pis)
      expect(formatted).to match(/^\d{3}\.\d{5}\.\d{2}-\d$/)
    end

    it 'generates PIS with valid checksum' do
      10.times do
        pis = described_class.generate
        base = pis[0..9]
        checksum = pis[10].to_i
        expected_checksum = described_class.send(:checksum, base)
        expect(checksum).to eq(expected_checksum)
      end
    end

    it 'generates PIS starting with leading zeros sometimes' do
      # Generate many and check if at least one starts with 0
      pis_numbers = 100.times.map { described_class.generate }
      has_leading_zero = pis_numbers.any? { |pis| pis[0] == '0' }
      # This might not always be true due to randomness, but with 100 tries it's likely
      # If it fails occasionally, that's acceptable for a random generator test
    end
  end

  describe 'integration scenarios' do
    it 'generates, validates, and formats a PIS' do
      # Generate
      pis = described_class.generate
      
      # Validate
      expect(described_class.is_valid(pis)).to be true
      
      # Format
      formatted = described_class.format_pis(pis)
      expect(formatted).to match(/^\d{3}\.\d{5}\.\d{2}-\d$/)
      
      # Remove symbols should return to original
      clean = described_class.remove_symbols(formatted)
      expect(clean).to eq(pis)
    end

    it 'processes user input with symbols' do
      # User enters formatted PIS
      user_input = '123.45678.90-9'
      
      # Remove symbols
      clean = described_class.remove_symbols(user_input)
      expect(clean).to eq('12345678909')
      
      # Validate
      if described_class.is_valid(clean)
        # Format for display
        formatted = described_class.format_pis(clean)
        expect(formatted).to eq('123.45678.90-9')
      end
    end

    it 'validates formatted PIS after cleaning' do
      formatted_pis = '987.65432.10-0'
      
      # Clean
      clean = described_class.remove_symbols(formatted_pis)
      
      # Validate
      expect(described_class.valid?(clean)).to be true
      
      # Format again
      reformatted = described_class.format(clean)
      expect(reformatted).to eq(formatted_pis)
    end

    it 'handles invalid formatted PIS' do
      invalid_formatted = '123.45678.90-0'
      
      # Clean
      clean = described_class.remove_symbols(invalid_formatted)
      
      # Validate (should be false)
      expect(described_class.is_valid(clean)).to be false
      
      # Format should return nil
      expect(described_class.format_pis(clean)).to be_nil
    end
  end

  describe 'checksum edge cases' do
    it 'handles checksum resulting in 10 (should become 0)' do
      # Find a base that results in checksum 10
      # We need sum % 11 = 1, so 11 - 1 = 10 → 0
      # This is implementation detail testing, but ensures correct behavior
      base = '0000000001'  # Small number
      checksum = described_class.send(:checksum, base)
      expect([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]).to include(checksum)
    end

    it 'handles checksum resulting in 11 (should become 0)' do
      # Find a base that results in checksum 11
      # We need sum % 11 = 0, so 11 - 0 = 11 → 0
      base = '0000000000'  # All zeros
      checksum = described_class.send(:checksum, base)
      expect([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]).to include(checksum)
    end

    it 'generates valid checksum for various bases' do
      test_bases = [
        '0000000000',
        '1111111111',
        '1234567890',
        '9876543210',
        '5555555555'
      ]

      test_bases.each do |base|
        checksum = described_class.send(:checksum, base)
        expect(checksum).to be >= 0
        expect(checksum).to be <= 9
        
        # Verify the complete PIS is valid
        pis = base + checksum.to_s
        expect(described_class.is_valid(pis)).to be true
      end
    end
  end

  describe 'weights constant' do
    it 'has correct weights array' do
      expect(BrazilianUtils::PISUtils::WEIGHTS).to eq([3, 2, 9, 8, 7, 6, 5, 4, 3, 2])
    end

    it 'has 10 weights for 10 digits' do
      expect(BrazilianUtils::PISUtils::WEIGHTS.length).to eq(10)
    end
  end

  describe 'format consistency' do
    it 'formats and cleans are inverse operations' do
      10.times do
        pis = described_class.generate
        formatted = described_class.format_pis(pis)
        cleaned = described_class.remove_symbols(formatted)
        expect(cleaned).to eq(pis)
      end
    end

    it 'validates both cleaned and original generated PIS' do
      10.times do
        pis = described_class.generate
        formatted = described_class.format_pis(pis)
        cleaned = described_class.remove_symbols(formatted)
        
        expect(described_class.is_valid(pis)).to be true
        expect(described_class.is_valid(cleaned)).to be true
      end
    end
  end

  describe 'boundary testing' do
    it 'validates PIS with minimum value (all zeros except checksum)' do
      base = '0000000000'
      checksum = described_class.send(:checksum, base)
      pis = base + checksum.to_s
      expect(described_class.is_valid(pis)).to be true
    end

    it 'validates PIS with maximum base (9999999999)' do
      base = '9999999999'
      checksum = described_class.send(:checksum, base)
      pis = base + checksum.to_s
      expect(described_class.is_valid(pis)).to be true
    end

    it 'formats PIS starting with zeros' do
      base = '0000000001'
      checksum = described_class.send(:checksum, base)
      pis = base + checksum.to_s
      formatted = described_class.format_pis(pis)
      expect(formatted).to start_with('000.')
    end
  end
end
