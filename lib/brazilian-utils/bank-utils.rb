require 'json'

module BrazilianUtils
  # Utilities for looking up Brazilian banks by COMPE code or ISPB, sourced
  # from the Banco Central do Brasil STR participants list.
  module BankUtils
    DATA_FILE = File.join(File.dirname(__FILE__), 'data', 'banks.json')

    # @private
    def self.load_data
      @data ||= JSON.parse(File.read(DATA_FILE))
    end

    private_class_method :load_data

    # @private
    def self.to_symbolized(row)
      { code: row['code'], ispb: row['ispb'], name: row['name'] }
    end

    private_class_method :to_symbolized

    # Looks a bank up by its 3-digit COMPE code.
    #
    # @param code [String, Integer] A number is read as the zero-padded
    #   3-digit code.
    # @return [Hash, nil]
    def self.get_by_code(code)
      return nil if code.nil?

      str = code.to_s.strip
      return nil unless str.match?(/\A\d+\z/)

      padded = str.rjust(3, '0')
      row = load_data.find { |r| r['code'] == padded }
      row && to_symbolized(row)
    end

    # Looks a bank up by its 8-digit ISPB.
    #
    # @param value [String, Integer] With or without leading zeros.
    # @return [Hash, nil]
    def self.get_by_ispb(value)
      return nil if value.nil?

      str = value.to_s.strip
      return nil unless str.match?(/\A\d+\z/)

      padded = str.rjust(8, '0')
      row = load_data.find { |r| r['ispb'] == padded }
      row && to_symbolized(row)
    end

    # Returns every bank with a COMPE code.
    #
    # @return [Array<Hash>]
    def self.list
      load_data.map { |row| to_symbolized(row) }
    end
  end
end
