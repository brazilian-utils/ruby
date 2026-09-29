module BrazilianUtils
  # Utilities for the CEI (Cadastro Específico do INSS), a 12-digit
  # registration number for a work/construction site or rural employer.
  module CEIUtils
    WEIGHTS = [7, 4, 1, 8, 5, 2, 1, 6, 3, 7, 4].freeze

    # @private
    def self.apply_mask(digits, group_sizes, separators)
      chunks = []
      idx = 0
      group_sizes.each do |size|
        break if idx >= digits.length

        chunks << digits[idx, size]
        idx += size
      end
      chunks.each_with_index.map { |c, i| i.zero? ? c : "#{separators[i - 1]}#{c}" }.join
    end

    private_class_method :apply_mask

    # @private
    def self.check_digit(base)
      sum = base.chars.each_with_index.sum { |d, i| d.to_i * WEIGHTS[i] }
      last_two = sum % 100
      combined = (last_two / 10) + (last_two % 10)
      (10 - (combined % 10)) % 10
    end

    private_class_method :check_digit

    # Validates a CEI: 12 digits, 11 base digits and one check digit.
    #
    # @param value [String, Integer] Bare digits, or split into the printed
    #   groups (2, 3, 5 and 2 digits) by whitespace or the usual mask
    #   characters (`.`, `-`, `/`).
    # @return [Boolean]
    def self.is_valid(value)
      return false unless value.is_a?(String) || value.is_a?(Integer)

      raw = value.to_s.strip
      return false unless raw.match?(%r{\A[\d\s.\-/]+\z})

      digits = raw.gsub(%r{[\s.\-/]}, '')
      return false unless digits.match?(/\A\d{12}\z/)
      return false if digits.chars.uniq.length == 1

      digits[11].to_i == check_digit(digits[0, 11])
    end

    class << self
      alias valid? is_valid
    end

    # Formats a CEI with the mask `00.000.00000/00`, applied as far as the
    # digits go.
    #
    # @param value [String, Integer]
    # @param options [Hash] `:pad` left-pads with zeros to 12 digits first.
    # @return [String]
    def self.format(value, options = {})
      digits = value.to_s.gsub(/\D/, '')
      digits = digits.rjust(12, '0') if options[:pad] || options['pad']
      return '' if digits.empty?

      apply_mask(digits, [2, 3, 5, 2], ['.', '.', '/'])
    end

    # Removes CEI formatting and keeps only digits, capped to 12 digits.
    #
    # @param value [String, Integer]
    # @return [String]
    def self.parse(value)
      return '' unless value.is_a?(String) || value.is_a?(Integer)

      value.to_s.gsub(/\D/, '')[0, 12]
    end
  end
end
