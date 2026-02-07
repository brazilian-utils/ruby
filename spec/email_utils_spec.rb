require 'spec_helper'

RSpec.describe BrazilianUtils::EmailUtils do
  describe '.is_valid' do
    context 'with valid email addresses' do
      it 'accepts simple email' do
        expect(described_class.is_valid('brutils@brutils.com')).to be true
      end

      it 'accepts email with subdomain' do
        expect(described_class.is_valid('user@mail.example.com')).to be true
      end

      it 'accepts email with dots in local part' do
        expect(described_class.is_valid('user.name@example.com')).to be true
      end

      it 'accepts email with multiple dots in local part' do
        expect(described_class.is_valid('first.middle.last@example.com')).to be true
      end

      it 'accepts email with plus sign' do
        expect(described_class.is_valid('user+tag@example.com')).to be true
      end

      it 'accepts email with underscore' do
        expect(described_class.is_valid('user_name@example.com')).to be true
      end

      it 'accepts email with numbers in local part' do
        expect(described_class.is_valid('user123@example.com')).to be true
      end

      it 'accepts email with numbers in domain' do
        expect(described_class.is_valid('user@example123.com')).to be true
      end

      it 'accepts email with hyphen in domain' do
        expect(described_class.is_valid('user@test-domain.com')).to be true
      end

      it 'accepts email with multiple hyphens in domain' do
        expect(described_class.is_valid('user@my-test-domain.com')).to be true
      end

      it 'accepts email with percent sign' do
        expect(described_class.is_valid('user%test@example.com')).to be true
      end

      it 'accepts email with two-letter TLD' do
        expect(described_class.is_valid('user@example.co')).to be true
      end

      it 'accepts email with three-letter TLD' do
        expect(described_class.is_valid('user@example.com')).to be true
      end

      it 'accepts email with four-letter TLD' do
        expect(described_class.is_valid('user@example.info')).to be true
      end

      it 'accepts email with long TLD' do
        expect(described_class.is_valid('user@example.travel')).to be true
      end

      it 'accepts email with multiple subdomains' do
        expect(described_class.is_valid('user@mail.server.example.com')).to be true
      end

      it 'accepts email with country code TLD' do
        expect(described_class.is_valid('user@example.br')).to be true
      end

      it 'accepts email with compound TLD' do
        expect(described_class.is_valid('user@example.co.uk')).to be true
      end

      it 'accepts email with all allowed special characters' do
        expect(described_class.is_valid('user.name+tag_123%test@example-domain.com')).to be true
      end

      it 'accepts uppercase letters in local part' do
        expect(described_class.is_valid('User@example.com')).to be true
      end

      it 'accepts uppercase letters in domain' do
        expect(described_class.is_valid('user@Example.com')).to be true
      end

      it 'accepts mixed case email' do
        expect(described_class.is_valid('User.Name@Example.COM')).to be true
      end
    end

    context 'with invalid email addresses' do
      it 'rejects email without TLD' do
        expect(described_class.is_valid('invalid-email@brutils')).to be false
      end

      it 'rejects email without domain' do
        expect(described_class.is_valid('user@')).to be false
      end

      it 'rejects email without local part' do
        expect(described_class.is_valid('@example.com')).to be false
      end

      it 'rejects email without @ symbol' do
        expect(described_class.is_valid('userexample.com')).to be false
      end

      it 'rejects email starting with dot' do
        expect(described_class.is_valid('.user@example.com')).to be false
      end

      it 'rejects email with space' do
        expect(described_class.is_valid('user name@example.com')).to be false
      end

      it 'rejects email with spaces in domain' do
        expect(described_class.is_valid('user@example .com')).to be false
      end

      it 'rejects email with multiple @ symbols' do
        expect(described_class.is_valid('user@@example.com')).to be false
      end

      it 'rejects email with @ at the end' do
        expect(described_class.is_valid('user@example.com@')).to be false
      end

      it 'rejects email with consecutive dots in local part' do
        expect(described_class.is_valid('user..name@example.com')).to be false
      end

      it 'rejects email ending with dot before @' do
        expect(described_class.is_valid('user.@example.com')).to be false
      end

      it 'rejects email with single letter TLD' do
        expect(described_class.is_valid('user@example.c')).to be false
      end

      it 'rejects email without dot in domain' do
        expect(described_class.is_valid('user@examplecom')).to be false
      end

      it 'rejects email with special characters in domain' do
        expect(described_class.is_valid('user@ex!ample.com')).to be false
      end

      it 'rejects email with brackets' do
        expect(described_class.is_valid('user[name]@example.com')).to be false
      end

      it 'rejects email with parentheses' do
        expect(described_class.is_valid('user(name)@example.com')).to be false
      end

      it 'rejects email with comma' do
        expect(described_class.is_valid('user,name@example.com')).to be false
      end

      it 'rejects email with semicolon' do
        expect(described_class.is_valid('user;name@example.com')).to be false
      end

      it 'rejects email with colon' do
        expect(described_class.is_valid('user:name@example.com')).to be false
      end

      it 'rejects email with quotes' do
        expect(described_class.is_valid('user"name"@example.com')).to be false
      end

      it 'rejects email with backslash' do
        expect(described_class.is_valid('user\\name@example.com')).to be false
      end

      it 'rejects email with forward slash' do
        expect(described_class.is_valid('user/name@example.com')).to be false
      end

      it 'rejects empty string' do
        expect(described_class.is_valid('')).to be false
      end

      it 'rejects string with only @' do
        expect(described_class.is_valid('@')).to be false
      end

      it 'rejects string with only domain' do
        expect(described_class.is_valid('example.com')).to be false
      end

      it 'rejects email with leading spaces' do
        expect(described_class.is_valid(' user@example.com')).to be false
      end

      it 'rejects email with trailing spaces' do
        expect(described_class.is_valid('user@example.com ')).to be false
      end

      it 'rejects email with newline' do
        expect(described_class.is_valid("user@example.com\n")).to be false
      end

      it 'rejects email with tab' do
        expect(described_class.is_valid("user@example.com\t")).to be false
      end

      it 'rejects email ending with hyphen in domain' do
        expect(described_class.is_valid('user@example-.com')).to be false
      end

      it 'rejects email starting with hyphen in domain' do
        expect(described_class.is_valid('user@-example.com')).to be false
      end

      it 'rejects TLD with numbers' do
        expect(described_class.is_valid('user@example.c0m')).to be false
      end

      it 'rejects TLD with special characters' do
        expect(described_class.is_valid('user@example.co-m')).to be false
      end
    end

    context 'with non-string inputs' do
      it 'rejects nil' do
        expect(described_class.is_valid(nil)).to be false
      end

      it 'rejects integer' do
        expect(described_class.is_valid(123)).to be false
      end

      it 'rejects float' do
        expect(described_class.is_valid(12.34)).to be false
      end

      it 'rejects array' do
        expect(described_class.is_valid(['user@example.com'])).to be false
      end

      it 'rejects hash' do
        expect(described_class.is_valid({ email: 'user@example.com' })).to be false
      end

      it 'rejects boolean' do
        expect(described_class.is_valid(true)).to be false
      end

      it 'rejects symbol' do
        expect(described_class.is_valid(:email)).to be false
      end
    end

    context 'with real-world email examples' do
      it 'accepts Gmail address' do
        expect(described_class.is_valid('john.doe@gmail.com')).to be true
      end

      it 'accepts Outlook address' do
        expect(described_class.is_valid('jane.smith@outlook.com')).to be true
      end

      it 'accepts corporate email' do
        expect(described_class.is_valid('employee@company.com.br')).to be true
      end

      it 'accepts email with plus addressing (Gmail feature)' do
        expect(described_class.is_valid('user+newsletter@example.com')).to be true
      end

      it 'accepts email with numbers' do
        expect(described_class.is_valid('user2024@example.com')).to be true
      end

      it 'accepts Brazilian domain' do
        expect(described_class.is_valid('contato@brutils.com.br')).to be true
      end
    end
  end

  describe '.valid?' do
    it 'is an alias for is_valid' do
      expect(described_class.method(:valid?)).to eq(described_class.method(:is_valid))
    end

    it 'works the same as is_valid with valid email' do
      expect(described_class.valid?('user@example.com')).to be true
    end

    it 'works the same as is_valid with invalid email' do
      expect(described_class.valid?('invalid')).to be false
    end
  end
end
