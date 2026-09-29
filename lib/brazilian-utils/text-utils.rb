# frozen_string_literal: true

module BrazilianUtils
  # General-purpose text helpers used across the other domains (and useful
  # on their own) for handling names, company names and addresses written in
  # Brazilian Portuguese.
  module TextUtils
    # Prepositions and articles that stay lower case between two words.
    DEFAULT_PREPOSITIONS = %w[de da do das dos e].freeze

    # Company designations/abbreviations that are always upper-cased.
    # Deliberately conservative: common words that also happen to be valid
    # abbreviations (e.g. "me", the reflexive pronoun; "sa", the surname
    # "Sá") are left out on purpose, see `text.capitalize`'s description.
    DEFAULT_DESIGNATIONS = %w[LTDA EPP MEI EIRELI CNPJ].freeze

    # Roman numerals commonly used in Brazilian company/entity names
    # (e.g. "Fundação XXI"). Only applied when the original token was
    # already written fully upper case, to avoid mistaking short
    # Portuguese words (like "vi", "mim") for numerals.
    ROMAN_NUMERALS = %w[
      I II III IV V VI VII VIII IX X XI XII XIII XIV XV XVI XVII XVIII XIX XX
    ].freeze

    WORD_OR_SEPARATOR_REGEX = /[\p{L}\p{N}]+|[^\p{L}\p{N}]+/.freeze

    # Capitalizes the first letter of each word the way a Brazilian name,
    # company name or address is written.
    #
    # @param value [String] The text to capitalize.
    # @param options [Hash] `:prepositions` and `:designations` replace the
    #   default lists.
    # @return [String] The capitalized text, or an empty string for empty
    #   input.
    #
    # @example
    #   capitalize("esponja vegetal")   #=> "Esponja Vegetal"
    #   capitalize("fulano de tal")     #=> "Fulano de Tal"
    #   capitalize("JOAQUIM JOSÉ")      #=> "Joaquim José"
    def self.capitalize(value, options = {})
      return '' unless value.is_a?(String)
      return '' if value.strip.empty?

      prepositions = (options[:prepositions] || options['prepositions'] || DEFAULT_PREPOSITIONS).map(&:downcase)
      designations = (options[:designations] || options['designations'] || DEFAULT_DESIGNATIONS).map(&:upcase)

      collapsed = value.strip.gsub(/\s+/, ' ')
      tokens = collapsed.scan(WORD_OR_SEPARATOR_REGEX)

      word_indices = tokens.each_index.select { |i| tokens[i].match?(/\A[\p{L}\p{N}]+\z/) }
      first_word_idx = word_indices.first
      last_word_idx = word_indices.last

      word_indices.each do |i|
        token = tokens[i]

        if token.match?(/\A\d/)
          tokens[i] = token.downcase
          next
        end

        upcase_token = token.upcase

        if token == upcase_token && ROMAN_NUMERALS.include?(upcase_token)
          tokens[i] = upcase_token
          next
        end

        if designations.include?(upcase_token)
          tokens[i] = upcase_token
          next
        end

        downcase_token = token.downcase
        next_token = tokens[i + 1]
        followed_by_punctuation = !next_token.nil? && next_token != ' '

        if prepositions.include?(downcase_token) && i != first_word_idx && i != last_word_idx && !followed_by_punctuation
          tokens[i] = downcase_token
        else
          tokens[i] = token[0].upcase + token[1..-1].to_s.downcase
        end
      end

      tokens.join
    end

    # Removes diacritical marks (accents, tildes, cedillas) from a string.
    #
    # Every character is decomposed (Unicode NFD) and every combining mark
    # is dropped.
    #
    # @param value [String] The text to strip accents from.
    # @return [String] The text without diacritics.
    #
    # @example
    #   remove_accents("São Paulo")  #=> "Sao Paulo"
    #   remove_accents("Açaí")       #=> "Acai"
    def self.remove_accents(value)
      return '' unless value.is_a?(String)

      value.unicode_normalize(:nfd).gsub(/[̀-ͯ]/, '')
    end
  end
end
