require 'spec_helper'

RSpec.describe BrazilianUtils::LegalProcessUtils do
  describe '.remove_symbols' do
    it 'removes dots and hyphens' do
      expect(described_class.remove_symbols('123.45-678.901.234-56.7890')).to eq('12345678901234567890')
    end

    it 'removes dots' do
      expect(described_class.remove_symbols('1234567.8901234567890')).to eq('12345678901234567890')
    end

    it 'removes hyphens' do
      expect(described_class.remove_symbols('1234567-8901234567890')).to eq('12345678901234567890')
    end

    it 'handles strings without symbols' do
      expect(described_class.remove_symbols('12345678901234567890')).to eq('12345678901234567890')
    end

    it 'handles empty string' do
      expect(described_class.remove_symbols('')).to eq('')
    end

    it 'handles strings with only symbols' do
      expect(described_class.remove_symbols('.-.-.-')).to eq('')
    end

    it 'returns empty string for nil' do
      expect(described_class.remove_symbols(nil)).to eq('')
    end

    it 'returns empty string for non-string input' do
      expect(described_class.remove_symbols(123)).to eq('')
    end
  end

  describe '.format_legal_process' do
    it 'formats a 20-digit string correctly' do
      expect(described_class.format_legal_process('12345678901234567890')).to eq('1234567-89.0123.4.56.7890')
    end

    it 'formats another valid 20-digit string' do
      expect(described_class.format_legal_process('98765432109876543210')).to eq('9876543-21.0987.6.54.3210')
    end

    it 'formats with zeros' do
      expect(described_class.format_legal_process('00000000000000000000')).to eq('0000000-00.0000.0.00.0000')
    end

    it 'returns nil for strings with wrong length' do
      expect(described_class.format_legal_process('123')).to be_nil
    end

    it 'returns nil for strings with 19 digits' do
      expect(described_class.format_legal_process('1234567890123456789')).to be_nil
    end

    it 'returns nil for strings with 21 digits' do
      expect(described_class.format_legal_process('123456789012345678901')).to be_nil
    end

    it 'returns nil for strings with non-digits' do
      expect(described_class.format_legal_process('1234567890123456789a')).to be_nil
    end

    it 'returns nil for empty string' do
      expect(described_class.format_legal_process('')).to be_nil
    end

    it 'returns nil for nil input' do
      expect(described_class.format_legal_process(nil)).to be_nil
    end

    it 'returns nil for non-string input' do
      expect(described_class.format_legal_process(12345678901234567890)).to be_nil
    end
  end

  describe '.is_valid' do
    context 'with valid legal process IDs' do
      it 'validates a known valid ID' do
        expect(described_class.is_valid('68476506020233030000')).to be true
      end

      it 'validates another known valid ID' do
        expect(described_class.is_valid('51808233620233030000')).to be true
      end

      it 'validates formatted ID' do
        expect(described_class.is_valid('6847650-60.2023.3.03.0000')).to be true
      end

      it 'validates another formatted ID' do
        expect(described_class.is_valid('5180823-36.2023.3.03.0000')).to be true
      end
    end

    context 'with invalid legal process IDs' do
      it 'rejects short strings' do
        expect(described_class.is_valid('123')).to be false
      end

      it 'rejects strings with wrong length (19 digits)' do
        expect(described_class.is_valid('1234567890123456789')).to be false
      end

      it 'rejects strings with wrong length (21 digits)' do
        expect(described_class.is_valid('123456789012345678901')).to be false
      end

      it 'rejects IDs with wrong checksum' do
        expect(described_class.is_valid('12345678901234567890')).to be false
      end

      it 'rejects IDs with invalid orgao (0)' do
        expect(described_class.is_valid('1234567-89.2023.0.01.0000')).to be false
      end

      it 'rejects IDs with invalid tribunal for orgao' do
        # Orgao 1 only has tribunal 1, so tribunal 99 is invalid
        expect(described_class.is_valid('1234567-89.2023.1.99.0000')).to be false
      end

      it 'rejects IDs with invalid foro for orgao' do
        # Orgao 1 only has foro 0, so foro 9999 is invalid
        expect(described_class.is_valid('1234567-89.2023.1.01.9999')).to be false
      end

      it 'rejects empty string' do
        expect(described_class.is_valid('')).to be false
      end

      it 'rejects nil input' do
        expect(described_class.is_valid(nil)).to be false
      end

      it 'rejects non-string input' do
        expect(described_class.is_valid(12345678901234567890)).to be false
      end
    end

    context 'checksum validation' do
      it 'accepts ID with correct checksum' do
        # Generate a valid ID with correct checksum
        nnnnnnn = '1234567'
        year = '2023'
        orgao = '3'
        tr = '03'
        oooo = '0000'
        
        base = nnnnnnn + year + orgao + tr + oooo
        # Calculate expected checksum: 97 - ((base * 100) % 97)
        checksum = (97 - ((base.to_i * 100) % 97)).to_s.rjust(2, '0')
        
        id = "#{nnnnnnn}#{checksum}#{year}#{orgao}#{tr}#{oooo}"
        expect(described_class.is_valid(id)).to be true
      end

      it 'rejects ID with incorrect checksum' do
        # Use known format but with wrong checksum
        id = '1234567001234567890'  # Likely invalid checksum
        expect(described_class.is_valid(id)).to be false
      end
    end
  end

  describe '.valid?' do
    it 'is an alias for is_valid' do
      expect(described_class.method(:valid?)).to eq(described_class.method(:is_valid))
    end

    it 'works the same as is_valid with valid ID' do
      expect(described_class.valid?('68476506020233030000')).to be true
    end

    it 'works the same as is_valid with invalid ID' do
      expect(described_class.valid?('123')).to be false
    end
  end

  describe '.generate' do
    context 'with valid parameters' do
      it 'generates a 20-digit ID' do
        id = described_class.generate(2026, 3)
        expect(id).to match(/^\d{20}$/)
      end

      it 'generates valid ID with specified year' do
        id = described_class.generate(2026, 5)
        expect(id).to match(/^\d{20}$/)
        expect(id[9, 4]).to eq('2026')
      end

      it 'generates valid ID with specified orgao' do
        id = described_class.generate(2026, 8)
        expect(id).to match(/^\d{20}$/)
        expect(id[13, 1]).to eq('8')
      end

      it 'generates ID with correct checksum' do
        id = described_class.generate(2026, 3)
        expect(described_class.valid?(id)).to be true
      end

      it 'generates different IDs on multiple calls' do
        ids = 5.times.map { described_class.generate(2026, 5) }
        expect(ids.uniq.length).to be > 1
      end

      it 'uses current year by default' do
        id = described_class.generate
        current_year = Time.now.year.to_s
        expect(id[9, 4]).to eq(current_year)
      end

      it 'uses random orgao by default' do
        id = described_class.generate
        orgao = id[13, 1].to_i
        expect(orgao).to be_between(1, 9)
      end
    end

    context 'with invalid parameters' do
      it 'returns nil for year in the past' do
        past_year = Time.now.year - 1
        expect(described_class.generate(past_year, 5)).to be_nil
      end

      it 'returns nil for orgao 0' do
        expect(described_class.generate(2026, 0)).to be_nil
      end

      it 'returns nil for orgao 10' do
        expect(described_class.generate(2026, 10)).to be_nil
      end

      it 'returns nil for negative orgao' do
        expect(described_class.generate(2026, -1)).to be_nil
      end

      it 'returns nil for invalid orgao and past year' do
        past_year = Time.now.year - 1
        expect(described_class.generate(past_year, 10)).to be_nil
      end
    end

    context 'generated IDs structure' do
      it 'places year in correct position' do
        id = described_class.generate(2026, 5)
        expect(id[9, 4]).to eq('2026')
      end

      it 'places orgao in correct position' do
        id = described_class.generate(2026, 7)
        expect(id[13, 1]).to eq('7')
      end

      it 'has valid tribunal for orgao' do
        10.times do
          id = described_class.generate(2026, 5)
          expect(described_class.valid?(id)).to be true
        end
      end

      it 'has valid foro for orgao' do
        10.times do
          id = described_class.generate(2026, 8)
          expect(described_class.valid?(id)).to be true
        end
      end
    end

    context 'for all valid orgaos' do
      it 'generates valid IDs for orgao 1' do
        id = described_class.generate(2026, 1)
        expect(described_class.valid?(id)).to be true
      end

      it 'generates valid IDs for orgao 2' do
        id = described_class.generate(2026, 2)
        expect(described_class.valid?(id)).to be true
      end

      it 'generates valid IDs for orgao 3' do
        id = described_class.generate(2026, 3)
        expect(described_class.valid?(id)).to be true
      end

      it 'generates valid IDs for orgao 4' do
        id = described_class.generate(2026, 4)
        expect(described_class.valid?(id)).to be true
      end

      it 'generates valid IDs for orgao 5' do
        id = described_class.generate(2026, 5)
        expect(described_class.valid?(id)).to be true
      end

      it 'generates valid IDs for orgao 6' do
        id = described_class.generate(2026, 6)
        expect(described_class.valid?(id)).to be true
      end

      it 'generates valid IDs for orgao 7' do
        id = described_class.generate(2026, 7)
        expect(described_class.valid?(id)).to be true
      end

      it 'generates valid IDs for orgao 8' do
        id = described_class.generate(2026, 8)
        expect(described_class.valid?(id)).to be true
      end

      it 'generates valid IDs for orgao 9' do
        id = described_class.generate(2026, 9)
        expect(described_class.valid?(id)).to be true
      end
    end
  end

  describe 'integration tests' do
    it 'formats and validates generated ID' do
      id = described_class.generate(2026, 5)
      formatted = described_class.format_legal_process(id)
      expect(formatted).to match(/^\d{7}-\d{2}\.\d{4}\.\d\.\d{2}\.\d{4}$/)
      expect(described_class.valid?(formatted)).to be true
    end

    it 'removes symbols from formatted ID and validates' do
      id = described_class.generate(2026, 8)
      formatted = described_class.format_legal_process(id)
      cleaned = described_class.remove_symbols(formatted)
      expect(cleaned).to eq(id)
      expect(described_class.valid?(cleaned)).to be true
    end

    it 'validates real-world example' do
      # Known valid IDs from Python implementation
      expect(described_class.valid?('68476506020233030000')).to be true
      expect(described_class.valid?('51808233620233030000')).to be true
    end

    it 'formats real-world example' do
      formatted = described_class.format_legal_process('68476506020233030000')
      expect(formatted).to eq('6847650-60.2023.3.03.0000')
    end

    it 'complete workflow: generate, format, validate' do
      # Generate
      id = described_class.generate(2026, 3)
      expect(id).to be_a(String)
      expect(id.length).to eq(20)
      
      # Format
      formatted = described_class.format_legal_process(id)
      expect(formatted).to match(/^\d{7}-\d{2}\.\d{4}\.\d\.\d{2}\.\d{4}$/)
      
      # Validate
      expect(described_class.valid?(id)).to be true
      expect(described_class.valid?(formatted)).to be true
      
      # Remove symbols
      cleaned = described_class.remove_symbols(formatted)
      expect(cleaned).to eq(id)
    end
  end

  describe 'edge cases' do
    it 'handles ID with leading zeros' do
      id = described_class.generate(2026, 1)
      # May have leading zeros in sequential number
      expect(id).to match(/^\d{20}$/)
      expect(described_class.valid?(id)).to be true
    end

    it 'handles IDs with all same digits in sequential part' do
      # This tests if validation works with unusual patterns
      id = described_class.generate(2026, 5)
      expect(described_class.valid?(id)).to be true
    end

    it 'validates formatted ID with extra spaces (should fail)' do
      expect(described_class.valid?('6847650-60.2023.3.03.0000 ')).to be false
    end

    it 'validates ID with lowercase letters (should fail)' do
      expect(described_class.valid?('68476506020233030a00')).to be false
    end
  end
end
