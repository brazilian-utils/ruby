module BrazilianUtils
  # Utilities for the CAEPF (Cadastro de Atividade Econômica da Pessoa
  # Física): 14 digits — a 9-digit CPF base, a 3-digit sequence and 2 check
  # digits.
  module CAEPFUtils
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

    # Computes a CNPJ-style modulus 11 check digit (the same algorithm
    # `CNPJUtils` uses) over an arbitrary-length base.
    #
    # @private
    def self.hashdigit(base, position)
      weights = []
      (position - 8).downto(2) { |w| weights << w }
      9.downto(2) { |w| weights << w }

      val = base.chars.first(position - 1).zip(weights).sum { |d, w| d.to_i * w } % 11
      val < 2 ? 0 : 11 - val
    end

    private_class_method :hashdigit

    # @private
    def self.check_digits(base12)
      first = hashdigit(base12, 13)
      second = hashdigit(base12 + first.to_s, 14)
      ((first * 10 + second) + 12) % 100
    end

    private_class_method :check_digits

    # Validates a CAEPF: 14 digits, with both check digits following the
    # CNPJ modulus 11 rule, shifted by 12 (wrapping around 100).
    #
    # @param value [String, Integer] Masked as `000.000.000/000-00` or not.
    # @return [Boolean]
    def self.is_valid(value)
      return false unless value.is_a?(String) || value.is_a?(Integer)

      raw = value.to_s.strip
      return false unless raw.match?(%r{\A[\d\s.\-/]+\z})

      digits = raw.gsub(%r{[\s.\-/]}, '')
      return false unless digits.match?(/\A\d{14}\z/)
      return false if digits[0, 9].chars.uniq.length == 1

      digits[12, 2].to_i == check_digits(digits[0, 12])
    end

    class << self
      alias valid? is_valid
    end

    # Formats a CAEPF with the mask `000.000.000/000-00`, applied as far as
    # the digits go.
    #
    # @param value [String, Integer]
    # @param options [Hash] `:pad` left-pads with zeros to 14 digits first.
    # @return [String]
    def self.format(value, options = {})
      digits = value.to_s.gsub(/\D/, '')
      digits = digits.rjust(14, '0') if options[:pad] || options['pad']
      return '' if digits.empty?

      apply_mask(digits, [3, 3, 3, 3, 2], ['.', '.', '/', '-'])
    end

    # Removes CAEPF formatting and keeps only digits, capped to 14 digits.
    #
    # @param value [String, Integer]
    # @return [String]
    def self.parse(value)
      return '' unless value.is_a?(String) || value.is_a?(Integer)

      value.to_s.gsub(/\D/, '')[0, 14]
    end
  end
end
