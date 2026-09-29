module BrazilianUtils
  # Utilities for validating a payment card number (credit or debit) by its
  # structure and Luhn check digit. No brand detection, issuer range
  # lookup, expiry or CVV check is performed.
  module CreditCardUtils
    # Validates a payment card number: 12 to 19 digits and a Luhn check
    # digit.
    #
    # @param value [String, Integer] Whitespace, `.`, `-` and `/` are
    #   allowed anywhere between the digits; letters make it invalid. Pass
    #   a large number as a string to avoid floating-point precision loss.
    # @return [Boolean] A number whose digits are all the same is rejected
    #   even though it passes Luhn.
    def self.is_valid(value)
      return false unless value.is_a?(String) || value.is_a?(Integer)

      raw = value.to_s.strip
      return false unless raw.match?(%r{\A[\d\s.\-/]+\z})

      digits = raw.gsub(%r{[\s.\-/]}, '')
      return false unless digits.match?(/\A\d{12,19}\z/)
      return false if digits.chars.uniq.length == 1

      luhn_valid?(digits)
    end

    class << self
      alias valid? is_valid
    end

    # @private
    def self.luhn_valid?(digits)
      sum = 0
      digits.reverse.each_char.with_index do |ch, i|
        d = ch.to_i
        if i.odd?
          d *= 2
          d -= 9 if d > 9
        end
        sum += d
      end
      (sum % 10).zero?
    end

    private_class_method :luhn_valid?
  end
end
