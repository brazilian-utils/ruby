require 'json'

module BrazilianUtils
  # Utilities for formatting, validating, and generating Brazilian Legal Process IDs.
  #
  # A legal process ID (Número de Processo Judicial) is a 20-digit code that identifies
  # a legal case in the Brazilian judiciary system. The format is:
  # NNNNNNN-DD.AAAA.J.TR.OOOO
  #
  # Where:
  # - NNNNNNN: Sequential number (7 digits)
  # - DD: Verification digits (2 digits) - checksum
  # - AAAA: Year the process was filed (4 digits)
  # - J: Judicial segment (1 digit) - Orgão
  # - TR: Court (2 digits) - Tribunal
  # - OOOO: Court of origin (4 digits) - Foro
  #
  # This module does not verify if a legal process ID corresponds to a real case;
  # it only validates the format and structure of the ID.
  module LegalProcessUtils
    # Path to the JSON file containing valid tribunal and foro IDs
    DATA_FILE = File.join(File.dirname(__FILE__), 'data', 'legal_process_ids.json')

    # Removes specific symbols (dots and hyphens) from a legal process ID.
    #
    # This function takes a legal process ID as input and removes all occurrences
    # of the '.' and '-' characters from it.
    #
    # @param legal_process [String] A legal process ID containing symbols to be removed
    #
    # @return [String] The legal process ID string with the specified symbols removed
    #
    # @example
    #   remove_symbols("123.45-678.901.234-56.7890")
    #   #=> "12345678901234567890"
    #
    #   remove_symbols("9876543-21.0987.6.54.3210")
    #   #=> "98765432109876543210"
    #
    #   remove_symbols("1234567890123456789012345")
    #   #=> "1234567890123456789012345"
    def self.remove_symbols(legal_process)
      return '' unless legal_process.is_a?(String)
      
      legal_process.gsub('.', '').gsub('-', '')
    end

    # Formats a legal process ID into the standard format.
    #
    # Takes a 20-digit string and formats it as: NNNNNNN-DD.AAAA.J.TR.OOOO
    #
    # @param legal_process_id [String] A 20-digit string representing the legal process ID
    #
    # @return [String, nil] The formatted legal process ID, or nil if the input is invalid
    #
    # @example
    #   format_legal_process("12345678901234567890")
    #   #=> "1234567-89.0123.4.56.7890"
    #
    #   format_legal_process("98765432109876543210")
    #   #=> "9876543-21.0987.6.54.3210"
    #
    #   format_legal_process("123")
    #   #=> nil
    def self.format_legal_process(legal_process_id)
      return nil unless legal_process_id.is_a?(String)
      return nil unless legal_process_id =~ /^\d{20}$/

      # Extract fields: NNNNNNN DD AAAA J TR OOOO
      nnnnnnn = legal_process_id[0, 7]
      dd = legal_process_id[7, 2]
      aaaa = legal_process_id[9, 4]
      j = legal_process_id[13, 1]
      tr = legal_process_id[14, 2]
      oooo = legal_process_id[16, 4]

      "#{nnnnnnn}-#{dd}.#{aaaa}.#{j}.#{tr}.#{oooo}"
    end

    # Checks if a legal process ID is valid.
    #
    # This function validates:
    # 1. The format (20 digits)
    # 2. The checksum (DD verification digits)
    # 3. The tribunal (TR) and foro (OOOO) combination against the official table
    #
    # This function does not verify if the legal process ID corresponds to a real case;
    # it only validates the format and structure of the ID.
    #
    # @param legal_process_id [String] A digit-only or formatted string representing 
    #   the legal process ID
    #
    # @return [Boolean] Returns true if the legal process ID is valid, false otherwise
    #
    # @example
    #   is_valid("68476506020233030000")
    #   #=> true
    #
    #   is_valid("5180823-36.2023.3.03.0000")
    #   #=> true
    #
    #   is_valid("123")
    #   #=> false
    def self.is_valid(legal_process_id)
      return false unless legal_process_id.is_a?(String)

      clean_id = remove_symbols(legal_process_id)
      return false unless clean_id =~ /^\d{20}$/

      # Extract fields
      nnnnnnn = clean_id[0, 7]
      dd = clean_id[7, 2]
      aaaa = clean_id[9, 4]
      j = clean_id[13, 1]
      tr = clean_id[14, 2]
      oooo = clean_id[16, 4]

      # Validate checksum
      base_for_checksum = nnnnnnn + aaaa + j + tr + oooo
      expected_dd = checksum(base_for_checksum.to_i)
      return false unless dd == expected_dd

      # Validate tribunal and foro against JSON data
      validate_tribunal_and_foro(j.to_i, tr.to_i, oooo.to_i)
    end

    # Alias for is_valid to provide Ruby-style naming
    class << self
      alias valid? is_valid
    end

    # Generates a random legal process ID.
    #
    # @param year [Integer] The year for the legal process ID (default is current year).
    #   The year should not be in the past.
    # @param orgao [Integer] The judicial segment code (1-9) for the legal process ID
    #   (default is random)
    #
    # @return [String, nil] A randomly generated legal process ID (20 digits),
    #   or nil if arguments are invalid
    #
    # @example
    #   generate(2023, 5)
    #   #=> "51659517020235080562" (example, actual value is random)
    #
    #   generate()
    #   #=> "88031888120233030000" (uses current year and random orgao)
    #
    #   generate(2022, 10)
    #   #=> nil (year in the past, orgao out of range)
    def self.generate(year = Time.now.year, orgao = rand(1..9))
      return nil if year < Time.now.year
      return nil unless (1..9).include?(orgao)

      data = load_legal_process_data
      return nil unless data

      orgao_data = data["orgao_#{orgao}"]
      return nil unless orgao_data

      # Get random tribunal and foro
      tribunals = orgao_data['id_tribunal']
      foros = orgao_data['id_foro']
      
      tr = tribunals[rand(tribunals.length)].to_s.rjust(2, '0')
      oooo = foros[rand(foros.length)].to_s.rjust(4, '0')
      
      # Generate random sequential number
      nnnnnnn = rand(0..9999999).to_s.rjust(7, '0')
      
      # Calculate checksum
      base_for_checksum = nnnnnnn + year.to_s + orgao.to_s + tr + oooo
      dd = checksum(base_for_checksum.to_i)
      
      "#{nnnnnnn}#{dd}#{year}#{orgao}#{tr}#{oooo}"
    end

    # Calculates the checksum (verification digits) for a legal process ID.
    #
    # The checksum is calculated as: 97 - ((basenum * 100) % 97), padded to 2 digits.
    #
    # @param basenum [Integer] The base number for checksum calculation
    #   (without the verification digits)
    #
    # @return [String] The checksum value as a 2-digit string
    #
    # @private
    def self.checksum(basenum)
      result = 97 - ((basenum * 100) % 97)
      result.to_s.rjust(2, '0')
    end

    private_class_method :checksum

    # Validates if a tribunal and foro combination is valid for a given orgao.
    #
    # @param orgao [Integer] The judicial segment (1-9)
    # @param tribunal [Integer] The court number
    # @param foro [Integer] The court of origin number
    #
    # @return [Boolean] True if the combination is valid, false otherwise
    #
    # @private
    def self.validate_tribunal_and_foro(orgao, tribunal, foro)
      return false unless (1..9).include?(orgao)

      data = load_legal_process_data
      return false unless data

      orgao_data = data["orgao_#{orgao}"]
      return false unless orgao_data

      tribunals = orgao_data['id_tribunal']
      foros = orgao_data['id_foro']

      tribunals.include?(tribunal) && foros.include?(foro)
    end

    private_class_method :validate_tribunal_and_foro

    # Loads the legal process data from the JSON file.
    #
    # @return [Hash, nil] The parsed JSON data, or nil if the file cannot be loaded
    #
    # @private
    def self.load_legal_process_data
      return @legal_process_data if @legal_process_data

      if File.exist?(DATA_FILE)
        @legal_process_data = JSON.parse(File.read(DATA_FILE))
      else
        nil
      end
    rescue JSON::ParserError, Errno::ENOENT
      nil
    end

    private_class_method :load_legal_process_data
  end
end
