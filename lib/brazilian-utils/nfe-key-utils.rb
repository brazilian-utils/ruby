require_relative 'state-utils'

module BrazilianUtils
  # Utilities for the 44-digit DF-e (Documento Fiscal eletrônico) access
  # key shared by NF-e, NFC-e, CT-e, MDF-e, CT-e OS, GTV-e, BP-e, NF3e and
  # NFCom.
  #
  # @note For NFCom and NF3e (models 62 and 66) the numeric code (`cNF`)
  #   field is 7 digits rather than 8, which shifts the rest of the key;
  #   no test case exercised these two models, so {get_info} always uses
  #   the general 8-digit layout. Its `code`/`model` fields for a 62/66 key
  #   should be treated as unverified.
  module NfeKeyUtils
    LENGTH = 44

    ID_PREFIXES = %w[NFCom NF3e NFe CTe MDFe BPe].freeze

    VALID_MODELS = %w[55 65 57 58 67 64 63 66 62].freeze

    # @private
    def self.apply_mask(digits, group_size)
      digits.chars.each_slice(group_size).map(&:join).join(' ')
    end

    private_class_method :apply_mask

    # @private
    def self.strip_id_prefix(raw)
      prefix = ID_PREFIXES.find { |p| raw.start_with?(p) }
      prefix ? raw[prefix.length..-1] : raw
    end

    private_class_method :strip_id_prefix

    # Removes the formatting of a DF-e access key and keeps only digits,
    # capped to 44 digits. The XML `Id` prefixes are stripped first.
    #
    # @param value [String, Integer]
    # @return [String]
    def self.parse(value)
      return '' unless value.is_a?(String) || value.is_a?(Integer)

      raw = strip_id_prefix(value.to_s)
      raw.gsub(/\D/, '')[0, LENGTH]
    end

    # Formats a DF-e access key into groups of 4 digits separated by
    # spaces. Does not validate (use {is_valid}).
    #
    # @param value [String]
    # @param options [Hash] `:pad` left-pads with zeros to 44 digits first.
    # @return [String]
    def self.format(value, options = {})
      raw = value.is_a?(String) ? strip_id_prefix(value) : value.to_s
      digits = raw.gsub(/\D/, '')
      digits = digits.rjust(LENGTH, '0') if options[:pad] || options['pad']
      return '' if digits.empty?

      apply_mask(digits, 4)
    end

    # @private
    def self.normalize(value)
      return nil unless value.is_a?(String)

      raw = strip_id_prefix(value.strip)
      return nil if raw.empty?

      digits = raw.gsub(%r{[\s.\-/]}, '')
      digits.match?(/\A\d{#{LENGTH}}\z/) ? digits : nil
    end

    private_class_method :normalize

    # @private
    def self.check_digit(base43)
      weights = []
      w = 2
      base43.length.times do
        weights << w
        w = w == 9 ? 2 : w + 1
      end
      weights.reverse!

      sum = base43.chars.each_with_index.sum { |d, i| d.to_i * weights[i] }
      r = sum % 11
      r < 2 ? 0 : 11 - r
    end

    private_class_method :check_digit

    # @private
    def self.cnf_ok?(cnf, nnf)
      return false if cnf.chars.uniq.length == 1
      return false if cnf.to_i == nnf.to_i

      digits = cnf.chars.map(&:to_i)
      ascending = digits.each_cons(2).all? { |a, b| b == (a + 1) % 10 }
      descending = digits.each_cons(2).all? { |a, b| b == (a - 1) % 10 }

      !(ascending || descending)
    end

    private_class_method :cnf_ok?

    # Validates a 44-digit DF-e access key.
    #
    # @param value [String]
    # @return [Boolean]
    def self.is_valid(value)
      digits = normalize(value)
      return false unless digits

      cuf = digits[0, 2]
      model = digits[20, 2]
      nnf = digits[25, 9]
      tpemis = digits[34, 1]
      cnf = digits[35, 8]
      cdv = digits[43, 1]

      return false unless StateUtils.get_by_ibge_code(cuf)
      return false unless VALID_MODELS.include?(model)
      return false unless tpemis.match?(/\A[1-9]\z/)
      return false if nnf.to_i.zero?
      return false if %w[55 65].include?(model) && !cnf_ok?(cnf, nnf)

      cdv.to_i == check_digit(digits[0, 43])
    end

    class << self
      alias valid? is_valid
    end

    # Parses a DF-e access key into its fields.
    #
    # @param value [String]
    # @return [Hash, nil] `nil` whenever {is_valid} would return false.
    def self.get_info(value)
      return nil unless is_valid(value)

      digits = normalize(value)
      state = StateUtils.get_by_ibge_code(digits[0, 2])

      {
        stateCode: state[:code],
        year: 2000 + digits[2, 2].to_i,
        month: digits[4, 2].to_i,
        taxId: digits[6, 14],
        model: digits[20, 2],
        series: digits[22, 3].to_i,
        number: digits[25, 9].to_i,
        emissionType: digits[34, 1].to_i,
        code: digits[35, 8],
        checkDigit: digits[43, 1].to_i
      }
    end
  end
end
