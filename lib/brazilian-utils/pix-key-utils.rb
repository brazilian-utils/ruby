require_relative 'cpf-utils'
require_relative 'cnpj-utils'
require_relative 'phone-utils'

module BrazilianUtils
  # Utilities for identifying and validating a Pix key (DICT key formats):
  # a CPF, a CNPJ, an email, a Brazilian mobile phone or a random EVP key.
  module PixKeyUtils
    UUID_REGEX = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i.freeze
    EMAIL_REGEX = /\A[^\s@]+@[^\s@]+\.[^\s@]+\z/.freeze
    MAX_EMAIL_LENGTH = 77

    # Identifies a Pix key and normalizes it to the canonical form the
    # DICT expects inside a BR Code.
    #
    # @param value [String]
    # @return [Hash, nil] `{ type:, value: }`, or nil when `value` is not a
    #   valid Pix key.
    def self.get_info(value)
      return nil unless value.is_a?(String)

      str = value.strip
      return nil if str.empty?

      return { type: 'evp', value: str.downcase } if UUID_REGEX.match?(str)

      if str.include?('@')
        return nil if str.length > MAX_EMAIL_LENGTH
        return nil unless EMAIL_REGEX.match?(str)

        return { type: 'email', value: str.downcase }
      end

      if str.start_with?('+') || str.include?('(')
        digits = PhoneUtils.parse(str)
        return nil unless PhoneUtils.is_valid_mobile(digits)

        return { type: 'phone', value: "+55#{digits}" }
      end

      digits = str.gsub(/\D/, '')
      case digits.length
      when 11
        CPFUtils.valid?(digits) ? { type: 'cpf', value: digits } : nil
      when 14
        CNPJUtils.valid?(digits) ? { type: 'cnpj', value: digits } : nil
      end
    end

    # Checks whether a value is a valid Pix key.
    #
    # @param value [String]
    # @param options [Hash] `:types` restricts the accepted key types
    #   (`%w[cpf cnpj email phone evp]`); an empty list rejects everything.
    # @return [Boolean]
    def self.is_valid(value, options = {})
      info = get_info(value)
      return false unless info

      types = options[:types] || options['types']
      return true if types.nil?

      types.map(&:to_s).include?(info[:type])
    end

    class << self
      alias valid? is_valid
    end
  end
end
