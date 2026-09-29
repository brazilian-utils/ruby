module BrazilianUtils
  # Utilities for the Brazilian IBAN: `BR` + 2 ISO 7064 MOD 97-10 check
  # digits + an 8-digit bank ISPB + a 5-digit branch + a 10-digit account +
  # a 1-letter account type + a 1-character owner indicator (29 characters
  # total).
  module IBANUtils
    LENGTH = 29

    # @private
    def self.apply_mask(chars, group_size)
      chars.chars.each_slice(group_size).map(&:join).join(' ')
    end

    private_class_method :apply_mask

    # Removes IBAN formatting, keeps letters and digits upper-cased, capped
    # to 29 characters.
    #
    # @param value [String, Integer]
    # @return [String]
    def self.parse(value)
      return '' unless value.is_a?(String) || value.is_a?(Integer)

      value.to_s.gsub(/[^a-zA-Z0-9]/, '').upcase[0, LENGTH]
    end

    # Formats an IBAN in the ISO 13616 print grouping: blocks of 4
    # characters separated by spaces, upper-cased. Does not validate (use
    # {is_valid}).
    #
    # @param value [String]
    # @return [String]
    def self.format(value)
      cleaned = parse(value)
      return '' if cleaned.empty?

      apply_mask(cleaned, 4)
    end

    # Normalizes an IBAN candidate, honoring the printed 4-character
    # grouping (a single whitespace, `.`, `-` or `/` between groups; a
    # separator inside a group is rejected).
    #
    # @return [String, nil]
    #
    # @private
    def self.normalize(value)
      return nil unless value.is_a?(String)

      raw = value.strip
      return nil if raw.empty?

      alnum_count = 0
      raw.each_char do |ch|
        if ch.match?(/[A-Za-z0-9]/)
          alnum_count += 1
        elsif ch.match?(%r{[\s.\-/]})
          return nil unless alnum_count.positive? && (alnum_count % 4).zero?
        else
          return nil
        end
      end

      compact = raw.gsub(%r{[\s.\-/]}, '').upcase
      compact.match?(/\A[A-Z0-9]{#{LENGTH}}\z/) ? compact : nil
    end

    private_class_method :normalize

    # @private
    def self.checksum_valid?(compact)
      rearranged = compact[4..-1] + compact[0, 4]
      numeric = rearranged.chars.map { |c| c.match?(/[A-Z]/) ? (c.ord - 55).to_s : c }.join
      numeric.to_i % 97 == 1
    end

    private_class_method :checksum_valid?

    # Validates a Brazilian IBAN; any other country is invalid.
    #
    # @param value [String]
    # @return [Boolean]
    def self.is_valid(value)
      compact = normalize(value)
      return false unless compact
      return false unless compact.start_with?('BR')
      return false unless compact[2, 2].match?(/\A\d{2}\z/)
      return false unless compact[4, 8].match?(/\A\d{8}\z/)
      return false unless compact[12, 5].match?(/\A\d{5}\z/)
      return false unless compact[17, 10].match?(/\A\d{10}\z/)
      return false unless compact[27, 1].match?(/\A[A-Z]\z/)
      return false unless compact[28, 1].match?(/\A[1-9A-Z]\z/)

      checksum_valid?(compact)
    end

    class << self
      alias valid? is_valid
    end

    # Parses a Brazilian IBAN into its fields.
    #
    # @param value [String]
    # @return [Hash, nil] `nil` whenever {is_valid} would return false.
    def self.get_info(value)
      return nil unless is_valid(value)

      compact = normalize(value)
      {
        countryCode: compact[0, 2],
        checkDigits: compact[2, 2],
        bankIspb: compact[4, 8],
        branch: compact[12, 5],
        account: compact[17, 10],
        accountType: compact[27, 1],
        owner: compact[28, 1]
      }
    end
  end
end
