require 'json'
require_relative 'text-utils'

module BrazilianUtils
  # Utilities for looking up Brazil's 27 federative units (states + the
  # Distrito Federal): code (sigla), name, region and IBGE code, sourced
  # from the IBGE Localidades API.
  module StateUtils
    DATA_FILE = File.join(File.dirname(__FILE__), 'data', 'states.json')

    # @private
    def self.load_data
      @data ||= JSON.parse(File.read(DATA_FILE))
    end

    private_class_method :load_data

    # @private
    def self.normalize_name(name)
      TextUtils.remove_accents(name.to_s).downcase.strip.gsub(/\s+/, ' ')
    end

    private_class_method :normalize_name

    # @private
    def self.to_symbolized(row)
      {
        code: row['code'],
        name: row['name'],
        regionCode: row['regionCode'],
        regionName: row['regionName'],
        ibgeCode: row['ibgeCode']
      }
    end

    private_class_method :to_symbolized

    # Returns the 27 Brazilian federative units, sorted by name (pt-BR
    # collation, approximated by comparing accent-stripped names).
    #
    # @return [Array<Hash>] Each entry has `:code`, `:name`, `:regionCode`,
    #   `:regionName` and `:ibgeCode`.
    def self.list
      load_data
        .sort_by { |row| normalize_name(row['name']) }
        .map { |row| to_symbolized(row) }
    end

    # Returns the state whose 2-digit IBGE code (cUF) matches `code`.
    #
    # @param code [String, Integer]
    # @return [Hash, nil]
    def self.get_by_ibge_code(code)
      return nil if code.nil?

      str = code.to_s.strip
      return nil unless str.match?(/\A\d+\z/)

      row = load_data.find { |r| r['ibgeCode'] == str.to_i }
      row && to_symbolized(row)
    end

    # Returns the two-letter code (sigla) of a state from its full name.
    #
    # @param name [String]
    # @return [String, nil]
    def self.get_code_by_name(name)
      return nil unless name.is_a?(String)

      normalized = normalize_name(name)
      return nil if normalized.empty?

      row = load_data.find { |r| normalize_name(r['name']) == normalized }
      row && row['code']
    end

    # Returns the full name of a state from its two-letter code (sigla).
    #
    # @param code [String]
    # @return [String, nil]
    def self.get_name_by_code(code)
      return nil unless code.is_a?(String)

      normalized = code.strip.upcase
      return nil if normalized.empty?

      row = load_data.find { |r| r['code'] == normalized }
      row && row['name']
    end

    # Returns the IANA time zone of a state (the zone of its capital).
    #
    # @param state_code [String]
    # @return [String, nil]
    def self.get_timezone(state_code)
      return nil unless state_code.is_a?(String)

      normalized = state_code.strip.upcase
      return nil if normalized.empty?

      row = load_data.find { |r| r['code'] == normalized }
      row && row['timezone']
    end
  end
end
