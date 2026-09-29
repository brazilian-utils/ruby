# frozen_string_literal: true

module BrazilianUtils
  module VoterIdUtils
    # UF codes mapping to federative union numbers
    UF_CODES = {
      'SP' => '01', 'MG' => '02', 'RJ' => '03', 'RS' => '04',
      'BA' => '05', 'PR' => '06', 'CE' => '07', 'PE' => '08',
      'SC' => '09', 'GO' => '10', 'MA' => '11', 'PB' => '12',
      'PA' => '13', 'ES' => '14', 'PI' => '15', 'RN' => '16',
      'AL' => '17', 'MT' => '18', 'MS' => '19', 'DF' => '20',
      'SE' => '21', 'AM' => '22', 'RO' => '23', 'AC' => '24',
      'AP' => '25', 'RR' => '26', 'TO' => '27', 'ZZ' => '28'
    }.freeze

    # Check if a Brazilian voter ID number is valid.
    #
    # @param voter_id [String] The voter ID to validate
    # @return [Boolean] true if valid, false otherwise
    def self.is_valid_voter_id(voter_id)
      # Ensure voter_id is a string with only digits and valid length
      return false unless voter_id.is_a?(String)
      return false unless voter_id.match?(/^\d+$/)
      return false unless is_length_valid?(voter_id)

      # Extract parts (using negative indexing for federative union and verifying digits)
      sequential_number = get_sequential_number(voter_id)
      federative_union = get_federative_union(voter_id)
      verifying_digits = get_verifying_digits(voter_id)

      # Validate federative union
      return false unless is_federative_union_valid?(federative_union)

      # Validate first verifying digit
      vd1 = calculate_vd1(sequential_number, federative_union)
      return false if vd1 != verifying_digits[0].to_i

      # Validate second verifying digit
      vd2 = calculate_vd2(federative_union, vd1)
      return false if vd2 != verifying_digits[1].to_i

      true
    end

    class << self
      # Alias for is_valid_voter_id
      alias valid_voter_id? is_valid_voter_id
    end

    # Format a voter ID for display with visual spaces.
    #
    # @param voter_id [String] The voter ID to format
    # @return [String, nil] Formatted voter ID or nil if invalid
    def self.format_voter_id(voter_id)
      return nil unless is_valid_voter_id(voter_id)

      # The 13-digit SP/MG variant has an extra sequential digit; grouping it
      # as 4+4+2+2 (like the 12-digit case) silently drops the last digit.
      if voter_id.length == 13
        "#{voter_id[0..3]} #{voter_id[4..7]} #{voter_id[8]} #{voter_id[9..10]} #{voter_id[11..12]}"
      else
        "#{voter_id[0..3]} #{voter_id[4..7]} #{voter_id[8..9]} #{voter_id[10..11]}"
      end
    end

    class << self
      # Alias for format_voter_id
      alias format format_voter_id
    end

    # Generate a random valid Brazilian voter ID.
    #
    # @param federative_union [String] The UF code (e.g., "SP", "MG", "ZZ")
    # @return [String, nil] A valid voter ID or nil if UF is invalid
    def self.generate(federative_union = 'ZZ')
      federative_union = federative_union.upcase
      return nil unless UF_CODES.key?(federative_union)

      uf_number = UF_CODES[federative_union]
      return nil unless is_federative_union_valid?(uf_number)

      # Generate random 8-digit sequential number
      # (uses rjust, not Kernel#format, since `format` is aliased to
      # format_voter_id on this module's singleton class below)
      sequential_number = rand(0..99_999_999).to_s.rjust(8, '0')

      # Calculate verification digits
      vd1 = calculate_vd1(sequential_number, uf_number)
      vd2 = calculate_vd2(uf_number, vd1)

      "#{sequential_number}#{uf_number}#{vd1}#{vd2}"
    end

    # PRIVATE METHODS
    #################

    # Check if the length of the voter ID is valid.
    # Typically 12 digits, but can be 13 for SP and MG (edge case).
    def self.is_length_valid?(voter_id)
      return true if voter_id.length == 12

      # Edge case: SP and MG can have 13 digits
      federative_union = get_federative_union(voter_id)
      voter_id.length == 13 && ['01', '02'].include?(federative_union)
    end

    # Extract the sequential number (first 8 digits).
    def self.get_sequential_number(voter_id)
      voter_id[0..7]
    end

    # Extract the federative union (2 digits before last 2 digits).
    def self.get_federative_union(voter_id)
      voter_id[-4..-3]
    end

    # Extract the verifying digits (last 2 digits).
    def self.get_verifying_digits(voter_id)
      voter_id[-2..-1]
    end

    # Check if the federative union is valid (between '01' and '28').
    def self.is_federative_union_valid?(federative_union)
      num = federative_union.to_i
      num >= 1 && num <= 28
    end

    # Calculate the first verifying digit.
    #
    # @param sequential_number [String] First 8 digits
    # @param federative_union [String] 2-digit UF code
    # @return [Integer] The first verification digit
    def self.calculate_vd1(sequential_number, federative_union)
      # Weights: 2, 3, 4, 5, 6, 7, 8, 9
      weights = (2..9).to_a

      sum = sequential_number.chars.each_with_index.sum do |digit, index|
        digit.to_i * weights[index]
      end

      rest = sum % 11
      vd1 = rest

      # Edge case: rest == 0 and federative_union is SP ('01') or MG ('02')
      vd1 = 1 if rest == 0 && ['01', '02'].include?(federative_union)

      # Edge case: rest == 10
      vd1 = 0 if rest == 10

      vd1
    end

    # Calculate the second verifying digit.
    #
    # @param federative_union [String] 2-digit UF code
    # @param vd1 [Integer] First verification digit
    # @return [Integer] The second verification digit
    def self.calculate_vd2(federative_union, vd1)
      # Weights: 7, 8, 9
      sum = (federative_union[0].to_i * 7) +
            (federative_union[1].to_i * 8) +
            (vd1 * 9)

      rest = sum % 11
      vd2 = rest

      # Edge case: rest == 0 and federative_union is SP ('01') or MG ('02')
      vd2 = 1 if rest == 0 && ['01', '02'].include?(federative_union)

      # Edge case: rest == 10
      vd2 = 0 if rest == 10

      vd2
    end

    private_class_method :is_length_valid?, :get_sequential_number, :get_federative_union,
                          :get_verifying_digits, :is_federative_union_valid?, :calculate_vd1,
                          :calculate_vd2

    # Removes the voter ID formatting symbols (spaces), keeping everything else.
    #
    # @param value [String] A voter ID, with or without spacing.
    # @return [String] The value with spaces removed.
    #
    # @example
    #   remove_symbols("1234 5678 01 24")  #=> "123456780124"
    def self.remove_symbols(value)
      return '' unless value.is_a?(String)

      value.gsub(/\s/, '')
    end

    # Removes voter ID formatting and keeps only digits, capped to 12 digits
    # (13 when the UF portion is SP or MG).
    #
    # @param value [String, Integer] A voter ID, with or without formatting.
    # @return [String] The parsed digits.
    #
    # @example
    #   parse("1234 5678 01 24")     #=> "123456780124"
    #   parse("1234 5678 8 01 91")   #=> "1234567880191" (13-digit SP/MG form)
    def self.parse(value)
      return '' unless value.is_a?(String) || value.is_a?(Integer)

      digits = value.to_s.gsub(/\D/, '')
      return '' if digits.empty?

      if digits.length > 12
        candidate = digits[0, 13]
        return candidate if candidate.length == 13 && %w[01 02].include?(candidate[-4..-3])
      end

      digits[0, 12]
    end
  end
end
