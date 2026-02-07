require 'spec_helper'

RSpec.describe BrazilianUtils::PhoneUtils do
  describe '.format_phone' do
    context 'when formatting valid mobile numbers' do
      it 'formats 11-digit mobile number' do
        expect(described_class.format_phone('11994029275')).to eq('(11)99402-9275')
      end

      it 'formats mobile number with DDD 21' do
        expect(described_class.format_phone('21987654321')).to eq('(21)98765-4321')
      end

      it 'formats mobile number with DDD 85' do
        expect(described_class.format_phone('85912345678')).to eq('(85)91234-5678')
      end

      it 'formats mobile number starting with 9' do
        expect(described_class.format_phone('47999887766')).to eq('(47)99988-7766')
      end
    end

    context 'when formatting valid landline numbers' do
      it 'formats 10-digit landline number' do
        expect(described_class.format_phone('1635014415')).to eq('(16)3501-4415')
      end

      it 'formats landline starting with 2' do
        expect(described_class.format_phone('1122334455')).to eq('(11)2233-4455')
      end

      it 'formats landline starting with 3' do
        expect(described_class.format_phone('2133445566')).to eq('(21)3344-5566')
      end

      it 'formats landline starting with 4' do
        expect(described_class.format_phone('8544556677')).to eq('(85)4455-6677')
      end

      it 'formats landline starting with 5' do
        expect(described_class.format_phone('4755667788')).to eq('(47)5566-7788')
      end
    end

    context 'when formatting fails' do
      it 'returns nil for invalid number' do
        expect(described_class.format_phone('333333')).to be_nil
      end

      it 'returns nil for too short number' do
        expect(described_class.format_phone('123456')).to be_nil
      end

      it 'returns nil for too long number' do
        expect(described_class.format_phone('123456789012')).to be_nil
      end

      it 'returns nil for empty string' do
        expect(described_class.format_phone('')).to be_nil
      end

      it 'returns nil for non-string input' do
        expect(described_class.format_phone(nil)).to be_nil
      end

      it 'returns nil for numeric input' do
        expect(described_class.format_phone(11994029275)).to be_nil
      end

      it 'returns nil for mobile with invalid DDD (starts with 0)' do
        expect(described_class.format_phone('01987654321')).to be_nil
      end

      it 'returns nil for landline with digit 6 after DDD' do
        expect(described_class.format_phone('1166778899')).to be_nil
      end
    end

    it 'has an alias method .format' do
      expect(described_class.format('11994029275')).to eq('(11)99402-9275')
    end
  end

  describe '.is_valid' do
    context 'when validating mobile numbers (without type specified)' do
      it 'validates 11-digit mobile number' do
        expect(described_class.is_valid('11994029275')).to be true
      end

      it 'validates mobile with DDD 21' do
        expect(described_class.is_valid('21987654321')).to be true
      end

      it 'validates mobile with DDD 85' do
        expect(described_class.is_valid('85912345678')).to be true
      end

      it 'validates mobile with DDD 11 and 9 prefix' do
        expect(described_class.is_valid('11999887766')).to be true
      end

      it 'validates mobile with all digits different' do
        expect(described_class.is_valid('12987654321')).to be true
      end

      it 'validates mobile with DDD 99' do
        expect(described_class.is_valid('99987654321')).to be true
      end
    end

    context 'when validating landline numbers (without type specified)' do
      it 'validates 10-digit landline number' do
        expect(described_class.is_valid('1635014415')).to be true
      end

      it 'validates landline starting with 2' do
        expect(described_class.is_valid('1122334455')).to be true
      end

      it 'validates landline starting with 3' do
        expect(described_class.is_valid('2133445566')).to be true
      end

      it 'validates landline starting with 4' do
        expect(described_class.is_valid('8544556677')).to be true
      end

      it 'validates landline starting with 5' do
        expect(described_class.is_valid('4755667788')).to be true
      end

      it 'validates landline with DDD 11' do
        expect(described_class.is_valid('1130001234')).to be true
      end
    end

    context 'when validating with specific type :mobile' do
      it 'validates mobile number' do
        expect(described_class.is_valid('11994029275', :mobile)).to be true
      end

      it 'rejects landline as mobile' do
        expect(described_class.is_valid('1635014415', :mobile)).to be false
      end

      it 'rejects invalid number as mobile' do
        expect(described_class.is_valid('123456', :mobile)).to be false
      end

      it 'validates with string "mobile"' do
        expect(described_class.is_valid('11994029275', 'mobile')).to be true
      end
    end

    context 'when validating with specific type :landline' do
      it 'validates landline number' do
        expect(described_class.is_valid('1635014415', :landline)).to be true
      end

      it 'rejects mobile as landline' do
        expect(described_class.is_valid('11994029275', :landline)).to be false
      end

      it 'rejects invalid number as landline' do
        expect(described_class.is_valid('123456', :landline)).to be false
      end

      it 'validates with string "landline"' do
        expect(described_class.is_valid('1635014415', 'landline')).to be true
      end
    end

    context 'when validation fails' do
      it 'rejects too short number' do
        expect(described_class.is_valid('123456')).to be false
      end

      it 'rejects too long number' do
        expect(described_class.is_valid('123456789012')).to be false
      end

      it 'rejects mobile with DDD starting with 0' do
        expect(described_class.is_valid('01987654321')).to be false
      end

      it 'rejects mobile with second digit 0' do
        expect(described_class.is_valid('10987654321')).to be false
      end

      it 'rejects landline with DDD starting with 0' do
        expect(described_class.is_valid('0135014415')).to be false
      end

      it 'rejects landline with digit 6 after DDD' do
        expect(described_class.is_valid('1166778899')).to be false
      end

      it 'rejects landline with digit 7 after DDD' do
        expect(described_class.is_valid('1177889900')).to be false
      end

      it 'rejects landline with digit 8 after DDD' do
        expect(described_class.is_valid('1188990011')).to be false
      end

      it 'rejects landline with digit 9 after DDD (would be mobile without 11 digits)' do
        expect(described_class.is_valid('1199001122')).to be false
      end

      it 'rejects mobile without 9 after DDD' do
        expect(described_class.is_valid('11887654321')).to be false
      end

      it 'rejects empty string' do
        expect(described_class.is_valid('')).to be false
      end

      it 'rejects nil' do
        expect(described_class.is_valid(nil)).to be false
      end

      it 'rejects numeric input' do
        expect(described_class.is_valid(11994029275)).to be false
      end

      it 'rejects alphabetic characters' do
        expect(described_class.is_valid('11ABC029275')).to be false
      end

      it 'rejects number with symbols' do
        expect(described_class.is_valid('(11)99402-9275')).to be false
      end
    end

    it 'has an alias method .valid?' do
      expect(described_class.valid?('11994029275')).to be true
    end
  end

  describe '.remove_symbols_phone' do
    it 'removes parentheses from phone number' do
      expect(described_class.remove_symbols_phone('(11)994029275')).to eq('11994029275')
    end

    it 'removes hyphens from phone number' do
      expect(described_class.remove_symbols_phone('11-99402-9275')).to eq('11994029275')
    end

    it 'removes plus sign from phone number' do
      expect(described_class.remove_symbols_phone('+5511994029275')).to eq('5511994029275')
    end

    it 'removes spaces from phone number' do
      expect(described_class.remove_symbols_phone('11 99402 9275')).to eq('11994029275')
    end

    it 'removes all common symbols' do
      expect(described_class.remove_symbols_phone('+55 (11) 99402-9275')).to eq('5511994029275')
    end

    it 'removes symbols from landline' do
      expect(described_class.remove_symbols_phone('(16) 3501-4415')).to eq('1635014415')
    end

    it 'returns unchanged string if no symbols' do
      expect(described_class.remove_symbols_phone('11994029275')).to eq('11994029275')
    end

    it 'returns empty string for empty input' do
      expect(described_class.remove_symbols_phone('')).to eq('')
    end

    it 'returns empty string for nil input' do
      expect(described_class.remove_symbols_phone(nil)).to eq('')
    end

    it 'returns empty string for non-string input' do
      expect(described_class.remove_symbols_phone(123)).to eq('')
    end

    it 'has an alias method .remove_symbols' do
      expect(described_class.remove_symbols('(11)99402-9275')).to eq('11994029275')
    end

    it 'has an alias method .sieve' do
      expect(described_class.sieve('(11)99402-9275')).to eq('11994029275')
    end
  end

  describe '.generate' do
    context 'when generating with default (random type)' do
      it 'generates a valid phone number' do
        phone = described_class.generate
        expect(described_class.is_valid(phone)).to be true
      end

      it 'generates a 10 or 11 digit phone number' do
        phone = described_class.generate
        expect([10, 11]).to include(phone.length)
      end

      it 'generates different numbers on multiple calls' do
        phones = 10.times.map { described_class.generate }
        expect(phones.uniq.length).to be > 1
      end
    end

    context 'when generating mobile explicitly' do
      it 'generates a valid mobile number' do
        phone = described_class.generate(:mobile)
        expect(described_class.is_valid(phone, :mobile)).to be true
      end

      it 'generates an 11-digit number' do
        phone = described_class.generate(:mobile)
        expect(phone.length).to eq(11)
      end

      it 'generates number with 9 as 3rd digit' do
        phone = described_class.generate(:mobile)
        expect(phone[2]).to eq('9')
      end

      it 'generates with string "mobile"' do
        phone = described_class.generate('mobile')
        expect(described_class.is_valid(phone, :mobile)).to be true
      end

      it 'generates different mobile numbers' do
        phones = 10.times.map { described_class.generate(:mobile) }
        expect(phones.uniq.length).to be > 1
      end
    end

    context 'when generating landline explicitly' do
      it 'generates a valid landline number' do
        phone = described_class.generate(:landline)
        expect(described_class.is_valid(phone, :landline)).to be true
      end

      it 'generates a 10-digit number' do
        phone = described_class.generate(:landline)
        expect(phone.length).to eq(10)
      end

      it 'generates number with 2-5 as 3rd digit' do
        phone = described_class.generate(:landline)
        expect(['2', '3', '4', '5']).to include(phone[2])
      end

      it 'generates with string "landline"' do
        phone = described_class.generate('landline')
        expect(described_class.is_valid(phone, :landline)).to be true
      end

      it 'generates different landline numbers' do
        phones = 10.times.map { described_class.generate(:landline) }
        expect(phones.uniq.length).to be > 1
      end
    end

    context 'when verifying generated numbers can be formatted' do
      it 'can format generated mobile' do
        phone = described_class.generate(:mobile)
        formatted = described_class.format_phone(phone)
        expect(formatted).to match(/^\(\d{2}\)\d{5}-\d{4}$/)
      end

      it 'can format generated landline' do
        phone = described_class.generate(:landline)
        formatted = described_class.format_phone(phone)
        expect(formatted).to match(/^\(\d{2}\)\d{4}-\d{4}$/)
      end
    end
  end

  describe '.remove_international_dialing_code' do
    context 'when removing international code' do
      it 'removes 55 from phone with country code' do
        expect(described_class.remove_international_dialing_code('5511994029275')).to eq('11994029275')
      end

      it 'removes +55 from phone with country code' do
        expect(described_class.remove_international_dialing_code('+5511994029275')).to eq('+11994029275')
      end

      it 'removes 55 from landline with country code' do
        expect(described_class.remove_international_dialing_code('551635014415')).to eq('1635014415')
      end

      it 'removes +55 from landline with country code' do
        expect(described_class.remove_international_dialing_code('+551635014415')).to eq('+1635014415')
      end

      it 'removes only first occurrence of 55' do
        expect(described_class.remove_international_dialing_code('555511994029275')).to eq('5511994029275')
      end
    end

    context 'when not removing code' do
      it 'keeps number without international code' do
        expect(described_class.remove_international_dialing_code('11994029275')).to eq('11994029275')
      end

      it 'keeps landline without international code' do
        expect(described_class.remove_international_dialing_code('1635014415')).to eq('1635014415')
      end

      it 'keeps number with spaces (length check fails)' do
        expect(described_class.remove_international_dialing_code('+55 11 99402-9275')).to eq('+55 11 99402-9275')
      end

      it 'keeps short number even with 55 in it' do
        expect(described_class.remove_international_dialing_code('5512345')).to eq('5512345')
      end

      it 'keeps number if removing would make it <= 11 chars' do
        # 13 chars total, but with spaces removed would be exactly 11
        # However, the function checks original length without spaces
        number = '5511994029275'  # 13 chars, removing 55 = 11 chars
        expect(described_class.remove_international_dialing_code(number)).to eq('11994029275')
      end
    end

    context 'when handling edge cases' do
      it 'returns empty string for nil input' do
        expect(described_class.remove_international_dialing_code(nil)).to eq('')
      end

      it 'returns empty string for non-string input' do
        expect(described_class.remove_international_dialing_code(123)).to eq('')
      end

      it 'returns empty string for empty input' do
        expect(described_class.remove_international_dialing_code('')).to eq('')
      end

      it 'handles number starting with 5 but not 55' do
        expect(described_class.remove_international_dialing_code('511994029275')).to eq('511994029275')
      end
    end
  end

  describe 'integration scenarios' do
    it 'cleans, validates, and formats a user input mobile number' do
      user_input = '+55 (11) 99402-9275'
      
      # Remove symbols
      clean = described_class.remove_symbols(user_input)
      expect(clean).to eq('5511994029275')
      
      # Remove international code
      without_code = described_class.remove_international_dialing_code(clean)
      expect(without_code).to eq('11994029275')
      
      # Validate
      expect(described_class.is_valid(without_code)).to be true
      expect(described_class.is_valid(without_code, :mobile)).to be true
      
      # Format
      formatted = described_class.format(without_code)
      expect(formatted).to eq('(11)99402-9275')
    end

    it 'cleans, validates, and formats a user input landline number' do
      user_input = '(16) 3501-4415'
      
      # Remove symbols
      clean = described_class.remove_symbols(user_input)
      expect(clean).to eq('1635014415')
      
      # Validate
      expect(described_class.is_valid(clean)).to be true
      expect(described_class.is_valid(clean, :landline)).to be true
      
      # Format
      formatted = described_class.format(clean)
      expect(formatted).to eq('(16)3501-4415')
    end

    it 'generates, validates, and formats a random phone' do
      # Generate
      phone = described_class.generate
      
      # Validate
      expect(described_class.valid?(phone)).to be true
      
      # Format
      formatted = described_class.format_phone(phone)
      expect(formatted).to match(/^\(\d{2}\)\d{4,5}-\d{4}$/)
      
      # Remove symbols should return to original
      clean = described_class.remove_symbols(formatted)
      expect(clean).to eq(phone)
    end
  end
end
