require 'spec_helper'

describe BrazilianUtils::CNHUtils do
  describe '.valid?' do
    context 'with valid CNH' do
      it 'validates CNH with correct format and verification digits' do
        expect(BrazilianUtils::CNHUtils.valid?('98765432100')).to be true
      end

      it 'validates CNH with symbols (ignores them)' do
        expect(BrazilianUtils::CNHUtils.valid?('987654321-00')).to be true
      end

      it 'validates CNH with spaces and dots' do
        expect(BrazilianUtils::CNHUtils.valid?('987.654.321-00')).to be true
      end

      # Additional valid CNHs for thorough testing
      it 'validates multiple valid CNH formats' do
        valid_cnhs = [
          '98765432100',
          '987654321-00',
          '987.654.321-00',
          '98765432100'
        ]

        valid_cnhs.each do |cnh|
          expect(BrazilianUtils::CNHUtils.valid?(cnh)).to be(true), "Expected #{cnh} to be valid"
        end
      end
    end

    context 'with invalid CNH' do
      it 'rejects CNH with invalid verification digits' do
        expect(BrazilianUtils::CNHUtils.valid?('12345678901')).to be false
      end

      it 'rejects CNH with letters' do
        expect(BrazilianUtils::CNHUtils.valid?('A2C45678901')).to be false
      end

      it 'rejects CNH with all same digits' do
        expect(BrazilianUtils::CNHUtils.valid?('00000000000')).to be false
        expect(BrazilianUtils::CNHUtils.valid?('11111111111')).to be false
        expect(BrazilianUtils::CNHUtils.valid?('22222222222')).to be false
        expect(BrazilianUtils::CNHUtils.valid?('33333333333')).to be false
        expect(BrazilianUtils::CNHUtils.valid?('44444444444')).to be false
        expect(BrazilianUtils::CNHUtils.valid?('55555555555')).to be false
        expect(BrazilianUtils::CNHUtils.valid?('66666666666')).to be false
        expect(BrazilianUtils::CNHUtils.valid?('77777777777')).to be false
        expect(BrazilianUtils::CNHUtils.valid?('88888888888')).to be false
        expect(BrazilianUtils::CNHUtils.valid?('99999999999')).to be false
      end

      it 'rejects CNH with less than 11 digits' do
        expect(BrazilianUtils::CNHUtils.valid?('123456789')).to be false
        expect(BrazilianUtils::CNHUtils.valid?('1234567890')).to be false
      end

      it 'rejects CNH with more than 11 digits' do
        expect(BrazilianUtils::CNHUtils.valid?('123456789012')).to be false
        expect(BrazilianUtils::CNHUtils.valid?('12345678901234')).to be false
      end

      it 'rejects empty string' do
        expect(BrazilianUtils::CNHUtils.valid?('')).to be false
      end

      it 'rejects nil' do
        expect(BrazilianUtils::CNHUtils.valid?(nil)).to be false
      end

      it 'rejects string with only symbols' do
        expect(BrazilianUtils::CNHUtils.valid?('---...')).to be false
      end

      it 'rejects string with mixed letters and numbers' do
        expect(BrazilianUtils::CNHUtils.valid?('ABC12345678')).to be false
      end
    end

    context 'edge cases' do
      it 'handles CNH as integer' do
        expect(BrazilianUtils::CNHUtils.valid?(98765432100)).to be true
      end

      it 'handles CNH with various separators' do
        expect(BrazilianUtils::CNHUtils.valid?('987 654 321 00')).to be true
        expect(BrazilianUtils::CNHUtils.valid?('987/654/321-00')).to be true
      end

      it 'rejects CNH with correct length but wrong verification digits' do
        expect(BrazilianUtils::CNHUtils.valid?('98765432199')).to be false
        expect(BrazilianUtils::CNHUtils.valid?('98765432101')).to be false
      end
    end

    context 'verification digit logic' do
      it 'correctly validates first verification digit' do
        # This tests the first verificator logic specifically
        # Using known valid CNH
        expect(BrazilianUtils::CNHUtils.valid?('98765432100')).to be true
      end

      it 'correctly validates second verification digit' do
        # This tests the second verificator logic specifically
        # Using known valid CNH
        expect(BrazilianUtils::CNHUtils.valid?('98765432100')).to be true
      end

      it 'rejects when only first digit is wrong' do
        # These would fail the first verificator check
        expect(BrazilianUtils::CNHUtils.valid?('98765432190')).to be false
      end

      it 'rejects when only second digit is wrong' do
        # These would fail the second verificator check
        expect(BrazilianUtils::CNHUtils.valid?('98765432101')).to be false
      end
    end
  end

  describe 'private methods' do
    it 'does not expose check_first_verificator' do
      expect(BrazilianUtils::CNHUtils).not_to respond_to(:check_first_verificator)
    end

    it 'does not expose check_second_verificator' do
      expect(BrazilianUtils::CNHUtils).not_to respond_to(:check_second_verificator)
    end
  end
end
