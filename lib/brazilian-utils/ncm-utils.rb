require 'json'

module BrazilianUtils
  # Utilities for the NCM (Nomenclatura Comum do Mercosul) table, the
  # current 8-digit ("leaf") code list published by Siscomex.
  module NCMUtils
    DATA_FILE = File.join(File.dirname(__FILE__), 'data', 'ncm.json')

    # @private
    def self.load_data
      @data ||= JSON.parse(File.read(DATA_FILE))
    end

    private_class_method :load_data

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

    # Normalizes an NCM value to its bare 8 digits: bare digits (string or
    # integer) are left-padded with zeros to 8; the `NNNN.NN.NN` mask is
    # read as written. Any other string is rejected.
    #
    # @private
    def self.normalize(value)
      return nil if value.nil?
      return value.to_s.rjust(8, '0') if value.is_a?(Integer)
      return nil unless value.is_a?(String)

      raw = value.strip
      return raw.rjust(8, '0') if raw.match?(/\A\d+\z/)

      m = raw.match(/\A(\d{4})\.(\d{2})\.(\d{2})\z/)
      m && "#{m[1]}#{m[2]}#{m[3]}"
    end

    private_class_method :normalize

    # Formats an NCM code with the mask `NNNN.NN.NN`; the mask is applied
    # as far as the digits go (only the structure changes — use {is_valid}
    # to check the code).
    #
    # @param value [String, Integer]
    # @param options [Hash] `:pad` left-pads with zeros to 8 digits first.
    # @return [String] An empty string when there is no digit at all.
    def self.format(value, options = {})
      digits = value.to_s.gsub(/\D/, '')
      digits = digits.rjust(8, '0') if options[:pad] || options['pad']
      return '' if digits.empty?

      apply_mask(digits, [4, 2, 2], ['.', '.'])
    end

    # Checks whether an NCM code exists in the current table.
    #
    # @param value [String, Integer]
    # @return [Boolean]
    def self.is_valid(value)
      code = normalize(value)
      return false unless code

      load_data.key?(code)
    end

    class << self
      alias valid? is_valid
    end

    # Removes NCM formatting and keeps only digits, capped to 8 digits
    # (nothing is left-padded).
    #
    # @param value [String, Integer]
    # @return [String]
    def self.parse(value)
      return '' unless value.is_a?(String) || value.is_a?(Integer)

      value.to_s.gsub(/\D/, '')[0, 8]
    end
  end
end
