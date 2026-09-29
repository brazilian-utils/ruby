require 'json'

module BrazilianUtils
  # Utilities for the CNAE-Subclasses 2.3 table (the current subclass
  # revision of CNAE 2.0), sourced from the IBGE CONCLA API.
  module CNAEUtils
    DATA_FILE = File.join(File.dirname(__FILE__), 'data', 'cnae.json')

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

    # Normalizes a CNAE value to its bare 7 digits: bare digits (string or
    # integer) are left-padded with zeros to 7; the `NNNN-N/NN` mask is
    # read as written. Any other string is rejected.
    #
    # @private
    def self.normalize(value)
      return nil if value.nil?
      return value.to_s.rjust(7, '0') if value.is_a?(Integer)
      return nil unless value.is_a?(String)

      raw = value.strip
      return raw.rjust(7, '0') if raw.match?(/\A\d+\z/)

      m = raw.match(%r{\A(\d{4})-(\d)/(\d{2})\z})
      m && "#{m[1]}#{m[2]}#{m[3]}"
    end

    private_class_method :normalize

    # Formats a CNAE subclass code with the mask `NNNN-N/NN`; the mask is
    # applied as far as the digits go (only the structure changes — use
    # {is_valid} to check the code).
    #
    # @param value [String, Integer]
    # @param options [Hash] `:pad` left-pads with zeros to 7 digits first.
    # @return [String] An empty string when there is no digit at all.
    def self.format(value, options = {})
      digits = value.to_s.gsub(/\D/, '')
      digits = digits.rjust(7, '0') if options[:pad] || options['pad']
      return '' if digits.empty?

      apply_mask(digits, [4, 1, 2], ['-', '/'])
    end

    # Checks whether a CNAE subclass code exists in the table.
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

    # Looks a CNAE subclass code up and returns its (bare, 7-digit) code
    # and official description.
    #
    # @param value [String, Integer]
    # @return [Hash, nil]
    def self.get(value)
      code = normalize(value)
      return nil unless code

      description = load_data[code]
      description && { code: code, description: description }
    end

    # Removes CNAE formatting and keeps only digits, capped to 7 digits
    # (nothing is left-padded).
    #
    # @param value [String, Integer]
    # @return [String]
    def self.parse(value)
      return '' unless value.is_a?(String) || value.is_a?(Integer)

      value.to_s.gsub(/\D/, '')[0, 7]
    end
  end
end
