module BrazilianUtils
  # Utilities for the matrícula of a certidão de registro civil (art. 473
  # of the Código Nacional de Normas da Corregedoria Nacional de Justiça):
  # a 32-digit number grouped as 6-2-2-4-1-5-3-7-2 (registry CNS, acervo,
  # serviço, ano, tipo do livro, livro, folha, termo, 2 check digits).
  module CertidaoUtils
    # Maps the single-digit "tipo do livro" code to its name.
    BOOK_TYPES = {
      '1' => 'birth',
      '2' => 'marriage',
      '3' => 'religiousMarriage',
      '4' => 'death',
      '5' => 'stillbirth',
      '6' => 'banns',
      '7' => 'other',
      '8' => 'emancipation',
      '9' => 'interdiction'
    }.freeze

    FIELD_SIZES = [6, 2, 2, 4, 1, 5, 3, 7, 2].freeze
    FIELD_KEYS = %i[registryCns acervo service year type book page term checkDigits].freeze

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

    # Formats a matrícula into the printed groups (6-2-2-4-1-5-3-7-2),
    # separated by spaces, applied as far as the digits go.
    #
    # @param value [String, Integer]
    # @param options [Hash] `:pad` left-pads with zeros to 32 digits first.
    # @return [String]
    def self.format(value, options = {})
      digits = value.to_s.gsub(/\D/, '')
      digits = digits.rjust(32, '0') if options[:pad] || options['pad']
      return '' if digits.empty?

      apply_mask(digits, FIELD_SIZES, [' '] * 8)
    end

    # Removes the formatting of a certidão matrícula and keeps only
    # digits, capped to 32 digits.
    #
    # @param value [String, Integer]
    # @return [String]
    def self.parse(value)
      return '' unless value.is_a?(String) || value.is_a?(Integer)

      value.to_s.gsub(/\D/, '')[0, 32]
    end

    # @private
    #
    # Computes a single modulus-11 check digit over `base`: the weight
    # starts at 2 for the rightmost character and increases by 1 moving
    # left (no cap, no wraparound).
    def self.check_digit(base)
      weights = (2...(2 + base.length)).to_a.reverse
      sum = base.chars.each_with_index.sum { |d, i| d.to_i * weights[i] }
      remainder = sum % 11
      remainder < 2 ? 0 : 11 - remainder
    end

    private_class_method :check_digit

    # @private
    #
    # Only digits and the separators {space, '.', '-', '/'} are accepted
    # anywhere in the string; any other character makes the whole value
    # invalid. Returns the digits-only string, or nil when the input isn't
    # a String/Integer or contains a disallowed character.
    def self.clean_for_validation(value)
      return nil unless value.is_a?(String) || value.is_a?(Integer)

      raw = value.to_s
      return nil unless raw.match?(%r{\A[\d\s.\-/]*\z})

      raw.gsub(%r{[\s.\-/]}, '')
    end

    private_class_method :clean_for_validation

    # @private
    def self.extract_fields(digits)
      fields = {}
      idx = 0
      FIELD_KEYS.each_with_index do |key, i|
        size = FIELD_SIZES[i]
        fields[key] = digits[idx, size]
        idx += size
      end
      fields
    end

    private_class_method :extract_fields

    # Checks whether a certidão matrícula is structurally valid and its 2
    # modulus-11 check digits match.
    #
    # @param value [String, Integer] The matrícula, bare or separated by
    #   any mix of space, `.`, `-` or `/`. Any other character (a letter,
    #   for instance) anywhere in the value makes it invalid.
    # @param options [Hash] `:accept` an optional Array narrowing which
    #   book-type codes (as the raw digit string, e.g. `"1"`) or names
    #   (e.g. `"birth"`) are accepted; defaults to accepting all of 1-9.
    # @return [Boolean]
    def self.is_valid(value, options = {})
      digits = clean_for_validation(value)
      return false unless digits
      return false unless digits.match?(/\A\d{32}\z/)

      raw = extract_fields(digits)
      return false unless raw[:service] == '55'
      return false unless BOOK_TYPES.key?(raw[:type])

      accept = options[:accept] || options['accept']
      if accept
        accepted = Array(accept).map(&:to_s)
        return false unless accepted.include?(raw[:type]) || accepted.include?(BOOK_TYPES[raw[:type]])
      end

      base30 = digits[0, 30]
      dv1 = check_digit(base30)
      dv2 = check_digit(base30 + dv1.to_s)

      raw[:checkDigits] == "#{dv1}#{dv2}"
    end

    class << self
      alias valid? is_valid
    end

    # Parses a certidão matrícula into its fields.
    #
    # @param value [String, Integer] Same accepted forms as {is_valid}.
    # @param options [Hash] Same as {is_valid}.
    # @return [Hash, nil] `nil` whenever {is_valid} would return false;
    #   otherwise a Hash with `:registryCns`, `:acervo`, `:service`,
    #   `:year` (Integer), `:type` (the book-type name), `:book`, `:page`,
    #   `:term` and `:checkDigits`.
    def self.get_info(value, options = {})
      return nil unless is_valid(value, options)

      digits = clean_for_validation(value)
      raw = extract_fields(digits)

      {
        registryCns: raw[:registryCns],
        acervo: raw[:acervo],
        service: raw[:service],
        year: raw[:year].to_i,
        type: BOOK_TYPES[raw[:type]],
        book: raw[:book],
        page: raw[:page],
        term: raw[:term],
        checkDigits: raw[:checkDigits]
      }
    end
  end
end
