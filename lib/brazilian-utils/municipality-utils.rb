require 'json'
require_relative 'text-utils'

module BrazilianUtils
  # Utilities for looking up Brazilian municipalities by IBGE code, sourced
  # from the IBGE Localidades API (5,571 municipalities).
  module MunicipalityUtils
    DATA_FILE = File.join(File.dirname(__FILE__), 'data', 'municipalities.json')

    # @private
    def self.load_data
      @data ||= JSON.parse(File.read(DATA_FILE))
    end

    private_class_method :load_data

    # @private
    def self.to_symbolized(row)
      { code: row['code'], name: row['name'], stateCode: row['stateCode'] }
    end

    private_class_method :to_symbolized

    # Looks a municipality up by its 7-digit IBGE code.
    #
    # @param code [String, Integer]
    # @return [Hash, nil]
    def self.get_by_code(code)
      return nil if code.nil?

      str = code.to_s.gsub(/\D/, '')
      return nil unless str.length == 7

      row = load_data.find { |r| r['code'] == str }
      row && to_symbolized(row)
    end

    # Returns Brazilian municipalities, sorted by name (pt-BR collation).
    #
    # @param state_code [String, nil] Only that state's municipalities; when
    #   omitted, every municipality. An empty or unknown code returns an
    #   empty list (matching is case-sensitive).
    # @return [Array<Hash>]
    def self.list(state_code = nil)
      rows = load_data

      unless state_code.nil?
        return [] unless state_code.is_a?(String) && !state_code.empty?

        rows = rows.select { |r| r['stateCode'] == state_code }
      end

      rows
        .sort_by { |r| TextUtils.remove_accents(r['name']).downcase }
        .map { |r| to_symbolized(r) }
    end
  end
end
