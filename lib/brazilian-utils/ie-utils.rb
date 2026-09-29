module BrazilianUtils
  # Utilities for the Inscrição Estadual (IE), the state-level tax
  # registration number.
  #
  # @note This is deliberately a *structural-only* check: each of the 27
  #   Brazilian states (and the Distrito Federal) defines its own SINTEGRA
  #   check-digit algorithm for its IE, and the contract for this function
  #   does not supply a single test case exercising any of them. Without a
  #   verifiable reference, computing (and possibly getting wrong) 27
  #   different check-digit algorithms would be worse than only validating
  #   the one thing that is unambiguous per the contract: the expected
  #   digit count for each state. This mirrors the reference (Go)
  #   implementation, which takes the same structural-only approach for the
  #   same reason.
  module IEUtils
    # State (UF) -> accepted digit-count(s) after stripping mask
    # characters ({space, '.', '-', '/'}).
    DIGIT_COUNTS = {
      'AC' => [13],
      'AL' => [9],
      'AM' => [9],
      'AP' => [9],
      'BA' => [8, 9],
      'CE' => [9],
      'DF' => [13],
      'ES' => [9],
      'GO' => [9],
      'MA' => [9],
      'MG' => [13],
      'MS' => [9],
      'MT' => [11],
      'PA' => [9],
      'PB' => [9],
      'PE' => [9, 14],
      'PI' => [9],
      'PR' => [10],
      'RJ' => [8],
      'RN' => [9, 10],
      'RO' => [9, 14],
      'RR' => [9],
      'RS' => [10],
      'SC' => [9],
      'SE' => [9],
      'SP' => [12],
      'TO' => [9, 11]
    }.freeze

    # Checks the *structure* of a state Inscrição Estadual: whether its
    # cleaned length matches one of the digit counts accepted by the given
    # UF. This never validates a per-state SINTEGRA check digit.
    #
    # @param value [String, Integer] The IE, bare or separated by any mix
    #   of space, `.`, `-` or `/`. For São Paulo, a value starting with
    #   `P`/`p` (a produtor rural registration) is accepted when its
    #   cleaned length is exactly 13.
    # @param state [String] The two-letter UF code (case-insensitive).
    # @return [Boolean] false for an unknown UF or empty/invalid input.
    def self.is_valid(value, state)
      return false unless value.is_a?(String) || value.is_a?(Integer)

      uf = state.to_s.strip.upcase
      counts = DIGIT_COUNTS[uf]
      return false unless counts

      raw = value.to_s.strip
      return false if raw.empty?

      cleaned = raw.gsub(%r{[\s.\-/]}, '')
      return false if cleaned.empty?

      if uf == 'SP' && cleaned.start_with?('P', 'p')
        return cleaned.length == 13
      end

      return false unless cleaned.match?(/\A\d+\z/)

      counts.include?(cleaned.length)
    end

    class << self
      alias valid? is_valid
    end
  end
end
