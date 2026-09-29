require 'spec_helper'

RSpec.describe BrazilianUtils::BankAccountUtils do
  # NOTE: no acceptance cases were available in the contract for this
  # function (empty `cases: []`), and the bank-specific check-digit
  # algorithms are not implemented (see the module doc). These specs only
  # cover the structural rules and the generic mod10/mod11 fallback this
  # implementation actually performs.

  describe '.is_valid' do
    it 'rejects a bank code that is not a known COMPE participant' do
      params = { bankCode: '999', agency: '1234', account: '123456', digit: '0' }
      expect(described_class.is_valid(params)).to be false
    end

    it 'rejects an agency longer than 5 digits' do
      params = { bankCode: '001', agency: '123456', account: '123456', digit: '0' }
      expect(described_class.is_valid(params)).to be false
    end

    it 'rejects an account longer than 13 digits' do
      params = { bankCode: '001', agency: '1234', account: '12345678901234', digit: '0' }
      expect(described_class.is_valid(params)).to be false
    end

    it 'accepts the literal X digit (e.g. Banco do Brasil)' do
      params = { bankCode: '001', agency: '1234', account: '123456', digit: 'X' }
      expect(described_class.is_valid(params)).to be true
    end

    it 'accepts the literal P digit (e.g. Bradesco)' do
      params = { bankCode: '237', agency: '1234', account: '123456', digit: 'P' }
      expect(described_class.is_valid(params)).to be true
    end

    it 'rejects a non-Hash argument' do
      expect(described_class.is_valid('not a hash')).to be false
    end

    it 'validates a generic account whose digit matches the mod11 fallback' do
      # account "123456", mod11 weights [2,3,4,5,6,7,8,9] applied right-to-left:
      # 6*2 + 5*3 + 4*4 + 3*5 + 2*6 + 1*7 = 12+15+16+15+12+7 = 77; 77 % 11 = 0 -> 11-0=11 -> 0
      params = { bankCode: '341', agency: '1234', account: '123456', digit: '0' }
      expect(described_class.is_valid(params)).to be true
    end
  end

  describe '.valid?' do
    it 'is an alias for is_valid' do
      expect(described_class.method(:valid?)).to eq(described_class.method(:is_valid))
    end
  end
end
