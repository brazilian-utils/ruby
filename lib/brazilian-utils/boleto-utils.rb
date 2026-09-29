# frozen_string_literal: true

require 'date'

module BrazilianUtils
  module BoletoUtils
    # The fator de vencimento epoch (day 1000) before the 2025-02-22 cycle
    # reset, and how many days apart the two candidate dates for a given
    # factor are, per the contract's own description. Not independently
    # verified against a reference implementation (no test cases were
    # available for `boleto.getInfo`).
    FATOR_VENCIMENTO_OLD_EPOCH = Date.new(1997, 10, 7)
    FATOR_VENCIMENTO_CYCLE_GAP_DAYS = 9000
    # Every Digitable Line from Boleto has exactly 47 characters
    DIGITABLE_LINE_LENGTH = 47

    # Positions to convert digitable line to boleto
    DIGITABLE_LINE_TO_BOLETO_CONVERT_POSITIONS = [
      { start: 0, end: 4 },
      { start: 32, end: 47 },
      { start: 4, end: 9 },
      { start: 10, end: 20 },
      { start: 21, end: 31 }
    ].freeze

    # Partials to verify with mod10
    PARTIALS_TO_VERIFY_MOD10 = [
      { start: 0, end: 9, digit_index: 9 },
      { start: 10, end: 20, digit_index: 20 },
      { start: 21, end: 31, digit_index: 31 }
    ].freeze

    # Mod10 weights
    MOD10_WEIGHTS = [2, 1].freeze

    # Check digit mod11 position
    CHECK_DIGIT_MOD11_POSITION = 4

    # Mod11 weights configuration
    MOD11_WEIGHTS = {
      initial: 2,
      end: 9,
      increment: 1
    }.freeze

    class << self
      # Validates if a given Digitable Line is valid.
      #
      # @param digitable_line [String] The boleto digitable line to validate
      # @return [Boolean] true if valid, false otherwise
      def is_valid(digitable_line)
        # Extract only numbers from the input
        digitable_line_numbers = extract_only_numbers(digitable_line)

        return false unless valid_length?(digitable_line_numbers)
        return false unless validate_digitable_line_partials(digitable_line_numbers)

        validate_mod11_check_digit(digitable_line_numbers)
      end

      # Alias for is_valid
      alias valid? is_valid

      # Removes boleto formatting and keeps only digits, capped to 47
      # digits (48 for a boleto de arrecadação, recognized by a leading
      # `8`).
      #
      # @param value [String, Integer]
      # @return [String]
      def parse(value)
        return '' unless value.is_a?(String) || value.is_a?(Integer)

        digits = value.to_s.gsub(/\D/, '')
        return '' if digits.empty?

        cap = digits[0] == '8' ? 48 : 47
        digits[0, cap]
      end

      # @private
      def apply_mask(digits, group_sizes, separators)
        chunks = []
        idx = 0
        group_sizes.each do |size|
          break if idx >= digits.length

          chunks << digits[idx, size]
          idx += size
        end
        chunks.each_with_index.map { |c, i| i.zero? ? c : "#{separators[i - 1]}#{c}" }.join
      end

      # Formats a boleto linha digitável with its printed mask.
      #
      # @param value [String, Integer]
      # @param options [Hash] `:pad` left-pads the value with zeros to the
      #   length of the pattern before masking.
      # @return [String]
      def format(value, options = {})
        digits = value.to_s.gsub(/\D/, '')
        pad = options[:pad] || options['pad']

        if pad
          target = digits[0] == '8' ? 48 : 47
          digits = digits.rjust(target, '0')
        end

        return '' if digits.empty?

        if digits.length == 48 && digits[0] == '8'
          digits.chars.each_slice(12).map { |b| b.join }.map do |block|
            block.length > 11 ? "#{block[0, 11]}-#{block[11]}" : block
          end.join(' ')
        else
          apply_mask(digits, [5, 5, 5, 6, 5, 6, 1, 14], ['.', ' ', '.', ' ', '.', ' ', ' '])
        end
      end

      # Generates a valid random boleto number.
      #
      # @param params [Hash] `:type` set to `"arrecadacao"` generates a
      #   48-digit boleto de arrecadação instead of the default 47-digit
      #   cobrança bancária linha digitável.
      # @return [String, nil] `nil` for `type: "arrecadacao"`: it is not
      #   implemented (this module's {is_valid} itself only recognizes the
      #   47-digit cobrança bancária form, so a generated arrecadação
      #   number could not be verified to round-trip through it).
      def generate(params = {})
        type = params[:type] || params['type']
        return nil if type.to_s == 'arrecadacao'

        banco = sprintf('%03d', rand(1..999))
        moeda = '9'
        campo_livre = 25.times.map { rand(0..9) }.join
        fator_vencimento = sprintf('%04d', rand(1000..9999))
        valor = sprintf('%010d', rand(0..9_999_999_999))

        campo1_free = campo_livre[0, 5]
        campo2 = campo_livre[5, 10]
        campo3 = campo_livre[15, 10]

        campo1 = "#{banco}#{moeda}#{campo1_free}"
        dv1 = get_mod10(campo1)
        dv2 = get_mod10(campo2)
        dv3 = get_mod10(campo3)

        barcode_without_dv = "#{banco}#{moeda}#{fator_vencimento}#{valor}#{campo_livre}"
        dv_geral = get_mod11(barcode_without_dv)

        "#{campo1}#{dv1}#{campo2}#{dv2}#{campo3}#{dv3}#{dv_geral}#{fator_vencimento}#{valor}"
      end

      # Extracts the amount, due date and bank code from a boleto.
      #
      # @note Only the 47-digit cobrança bancária form is supported; a
      #   boleto de arrecadação (48-digit linha digitável or 44-digit
      #   barcode) returns nil. The due-date resolution (fator de
      #   vencimento, including the 2025-02-22 cycle reset) has no
      #   available test cases and is unverified against a reference
      #   implementation.
      #
      # @param value [String]
      # @param options [Hash] `:referenceDate` resolves the fator de
      #   vencimento cycle as of that date (default: today).
      # @return [Hash, nil]
      def get_info(value, options = {})
        return nil unless is_valid(value)

        digits = extract_only_numbers(value)
        return nil unless digits.length == DIGITABLE_LINE_LENGTH

        barcode = parse_digitable_line(digits)
        bank_code = barcode[0, 3]
        fator_vencimento = barcode[5, 4].to_i
        amount_cents = barcode[9, 10].to_i

        reference_date = options[:referenceDate] || options['referenceDate'] || Date.today
        reference_date = reference_date.to_date if reference_date.respond_to?(:to_date)

        due_date =
          if fator_vencimento >= 1000
            date_a = FATOR_VENCIMENTO_OLD_EPOCH + (fator_vencimento - 1000)
            date_b = date_a + FATOR_VENCIMENTO_CYCLE_GAP_DAYS
            (date_a - reference_date).abs <= (date_b - reference_date).abs ? date_a : date_b
          end

        {
          bankCode: bank_code,
          amount: amount_cents,
          dueDate: due_date
        }
      end

      private

      # Extract only numeric characters from a string.
      #
      # @param str [String] The input string
      # @return [String] String containing only numeric characters
      def extract_only_numbers(str)
        return '' if str.nil?

        str.gsub(/\D/, '')
      end

      # Validates the string length.
      #
      # @param digitable_line [String] The digitable line to check
      # @return [Boolean] true if length is exactly 47, false otherwise
      def valid_length?(digitable_line)
        digitable_line.length == DIGITABLE_LINE_LENGTH
      end

      # Validates the digitable line partials using mod10.
      #
      # @param digitable_line [String] The digitable line to validate
      # @return [Boolean] true if all partials are valid, false otherwise
      def validate_digitable_line_partials(digitable_line)
        PARTIALS_TO_VERIFY_MOD10.all? do |partial|
          partial_str = digitable_line[partial[:start]...partial[:end]]
          mod10 = get_mod10(partial_str)
          digit = digitable_line[partial[:digit_index]].to_i
          digit == mod10
        end
      end

      # Calculate mod10 for a given partial string.
      #
      # @param partial [String] The partial string to calculate mod10 for
      # @return [Integer] The mod10 check digit
      def get_mod10(partial)
        sum = 0
        partial_reversed = partial.reverse

        partial_reversed.each_char.with_index do |char, index|
          partial_value = char.to_i
          weight = MOD10_WEIGHTS[index % 2]
          multiplier = partial_value * weight

          if multiplier > 9
            sum += 1 + (multiplier % 10)
          else
            sum += multiplier
          end
        end

        mod10 = sum % 10
        if mod10 > 0
          10 - mod10
        else
          0
        end
      end

      # Validates the mod11 check digit.
      #
      # @param digitable_line [String] The digitable line to validate
      # @return [Boolean] true if mod11 check digit is valid, false otherwise
      def validate_mod11_check_digit(digitable_line)
        parsed_digitable_line = parse_digitable_line(digitable_line)
        
        # Extract the value before and after the check digit position
        value = parsed_digitable_line[0...CHECK_DIGIT_MOD11_POSITION] +
                parsed_digitable_line[(CHECK_DIGIT_MOD11_POSITION + 1)..-1]
        
        mod11 = get_mod11(value)
        mod11_value = parsed_digitable_line[CHECK_DIGIT_MOD11_POSITION].to_i

        mod11_value == mod11
      end

      # Parse the digitable line by extracting specific positions.
      #
      # @param digitable_line [String] The digitable line to parse
      # @return [String] The parsed digitable line
      def parse_digitable_line(digitable_line)
        result = ''
        DIGITABLE_LINE_TO_BOLETO_CONVERT_POSITIONS.each do |position|
          result += digitable_line[position[:start]...position[:end]]
        end
        result
      end

      # Calculate mod11 for a given value string.
      #
      # @param value [String] The value string to calculate mod11 for
      # @return [Integer] The mod11 check digit
      def get_mod11(value)
        weight = MOD11_WEIGHTS[:initial]
        sum = 0
        value_reversed = value.reverse

        value_reversed.each_char do |char|
          value_value = char.to_i
          multiplier = value_value * weight

          if weight < MOD11_WEIGHTS[:end]
            weight += MOD11_WEIGHTS[:increment]
          else
            weight = MOD11_WEIGHTS[:initial]
          end

          sum += multiplier
        end

        mod11 = sum % 11
        if mod11 != 0 && mod11 != 1
          11 - mod11
        else
          1
        end
      end
    end
  end
end
