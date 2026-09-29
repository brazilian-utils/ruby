module BrazilianUtils
  # Utilities for the CNS (Cartão Nacional de Saúde) number: 15 digits,
  # definitive (starts with 1 or 2) or provisional (starts with 7, 8 or 9).
  module CNSUtils
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
    def self.weighted_sum(digits, weights)
      digits.chars.each_with_index.sum { |d, i| d.to_i * weights[i] }
    end

    private_class_method :weighted_sum

    # @private
    def self.definitive_valid?(digits)
      weights = (5..15).to_a.reverse # [15, 14, ..., 5]
      pis = digits[0, 11]

      sum = weighted_sum(pis, weights)
      resto = sum % 11
      dv = 11 - resto
      dv = 0 if dv == 11

      if dv == 10
        pis2 = (pis.to_i + 1).to_s.rjust(11, '0')
        sum2 = weighted_sum(pis2, weights)
        resto2 = sum2 % 11
        dv2 = 11 - resto2
        dv2 = 0 if dv2 >= 10
        digits == "#{pis2}001#{dv2}"
      else
        digits == "#{pis}000#{dv}"
      end
    end

    private_class_method :definitive_valid?

    # @private
    def self.provisional_valid?(digits)
      weights = (1..15).to_a.reverse # [15, 14, ..., 1]
      (weighted_sum(digits, weights) % 11).zero?
    end

    private_class_method :provisional_valid?

    # Validates a CNS number: 15 digits.
    #
    # @param value [String, Integer] The bare digits, or the printed
    #   3-4-4-4 groups split by whitespace, `.`, `-` or `/`.
    # @return [Boolean]
    def self.is_valid(value)
      return false unless value.is_a?(String) || value.is_a?(Integer)

      raw = value.to_s.strip
      return false unless raw.match?(%r{\A[\d\s.\-/]+\z})

      digits = raw.gsub(%r{[\s.\-/]}, '')
      return false unless digits.match?(/\A\d{15}\z/)

      case digits[0]
      when '1', '2'
        definitive_valid?(digits)
      when '7', '8', '9'
        provisional_valid?(digits)
      else
        false
      end
    end

    class << self
      alias valid? is_valid
    end

    # Formats a CNS number into 3-4-4-4 groups separated by spaces.
    #
    # @param value [String, Integer]
    # @param options [Hash] `:pad` left-pads with zeros to 15 digits first.
    # @return [String]
    def self.format(value, options = {})
      digits = value.to_s.gsub(/\D/, '')
      digits = digits.rjust(15, '0') if options[:pad] || options['pad']
      return '' if digits.empty?

      apply_mask(digits, [3, 4, 4, 4], [' ', ' ', ' '])
    end

    # Removes CNS formatting and keeps only digits, capped to 15 digits.
    #
    # @param value [String, Integer]
    # @return [String]
    def self.parse(value)
      return '' unless value.is_a?(String) || value.is_a?(Integer)

      value.to_s.gsub(/\D/, '')[0, 15]
    end
  end
end
