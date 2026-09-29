require_relative 'bank-utils'

module BrazilianUtils
  # Utilities for validating Brazilian bank accounts (bank code, agency,
  # account and check digit).
  #
  # @note This implementation validates the account's *structure* (a known
  #   COMPE `bankCode`, agency/account digit-count limits, an allowed
  #   `digit` character) and a generic modulus 10 / modulus 11 fallback
  #   check digit. The distinct, published check-digit algorithms some
  #   banks use (Banco do Brasil, Santander, Banrisul, Caixa, Bradesco,
  #   Nubank/Verhoeff, Itaú, HSBC/Kirton, Citibank) are **not** implemented:
  #   there were no verifiable test vectors available to confirm a from-
  #   scratch reproduction of each algorithm, and shipping an unverified
  #   guess would be worse than this honestly-partial generic check.
  module BankAccountUtils
    # @private
    def self.mod10_digit(digits)
      sum = 0
      digits.reverse.each_char.with_index do |ch, i|
        d = ch.to_i
        d *= 2 if i.even?
        d -= 9 if d > 9
        sum += d
      end
      (10 - (sum % 10)) % 10
    end

    private_class_method :mod10_digit

    # @private
    def self.mod11_digit(digits)
      weights = [2, 3, 4, 5, 6, 7, 8, 9]
      sum = 0
      digits.reverse.each_char.with_index do |ch, i|
        sum += ch.to_i * weights[i % weights.length]
      end
      rest = 11 - (sum % 11)
      rest >= 10 ? 0 : rest
    end

    private_class_method :mod11_digit

    # Validates a Brazilian bank account.
    #
    # @param params [Hash] `:bankCode` (3 digits), `:agency` (1-5 digits),
    #   `:account` (1-13 digits) and `:digit` (1-2 characters, or the
    #   literal `X`/`P` used by some banks), all strings.
    # @return [Boolean]
    def self.is_valid(params)
      return false unless params.is_a?(Hash)

      bank_code = params[:bankCode] || params['bankCode']
      agency = params[:agency] || params['agency']
      account = params[:account] || params['account']
      digit = params[:digit] || params['digit']

      return false unless [bank_code, agency, account, digit].all? { |v| v.is_a?(String) }
      return false unless BankUtils.get_by_code(bank_code)
      return false unless agency.match?(/\A\d{1,5}\z/)
      return false unless account.match?(/\A\d{1,13}\z/)
      return false unless digit.match?(/\A[0-9A-Za-z]{1,2}\z/)

      digit_upcase = digit.upcase
      return true if %w[X P].include?(digit_upcase) && digit.length == 1

      return false unless digit.match?(/\A\d{1,2}\z/)

      if digit.length == 2
        first_ok = digit[0].to_i == mod10_digit(account)
        second_ok = digit[1].to_i == mod11_digit(account + digit[0])
        first_ok && second_ok
      else
        digit.to_i == mod10_digit(account) || digit.to_i == mod11_digit(account)
      end
    end

    class << self
      alias valid? is_valid
    end
  end
end
