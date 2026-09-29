require 'json'

module BrazilianUtils
  # Utilities for the CSOSN (Código de Situação da Operação no Simples
  # Nacional) table (Ajuste SINIEF 07/2005).
  module CSOSNUtils
    DATA_FILE = File.join(File.dirname(__FILE__), 'data', 'csosn.json')

    # @private
    def self.load_data
      @data ||= JSON.parse(File.read(DATA_FILE))
    end

    private_class_method :load_data

    # Checks whether a value is one of the 10 official CSOSN codes.
    #
    # A CSOSN has no printed grouping/mask, so a value with any separator
    # is rejected.
    #
    # @param value [String, Integer]
    # @return [Boolean]
    def self.is_valid(value)
      return false if value.nil?

      str = value.to_s.strip
      return false unless str.match?(/\A\d{3}\z/)

      load_data.any? { |row| row['code'] == str }
    end

    class << self
      alias valid? is_valid
    end

    # Looks up the description of a CSOSN code.
    #
    # @param value [String, Integer]
    # @return [String, nil]
    def self.get_description(value)
      return nil if value.nil?

      str = value.to_s.strip
      row = load_data.find { |r| r['code'] == str }
      row && row['description']
    end

    # Returns all 10 official CSOSN entries.
    #
    # @return [Array<Hash>]
    def self.list
      load_data.map { |row| { code: row['code'], description: row['description'] } }
    end
  end
end
