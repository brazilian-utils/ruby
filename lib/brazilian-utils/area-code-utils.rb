require 'json'

module BrazilianUtils
  # Utilities for looking up Brazilian area codes (DDD), sourced from the
  # Anatel Plano Geral de Numeração.
  module AreaCodeUtils
    DATA_FILE = File.join(File.dirname(__FILE__), 'data', 'area_codes.json')

    # @private
    def self.load_data
      @data ||= JSON.parse(File.read(DATA_FILE))
    end

    private_class_method :load_data

    # @private
    def self.to_symbolized(row)
      {
        areaCode: row['areaCode'],
        stateCode: row['stateCode'],
        stateName: row['stateName'],
        regionCode: row['regionCode'],
        regionName: row['regionName'],
        stateCodes: row['stateCodes']
      }
    end

    private_class_method :to_symbolized

    # Returns the state and region a DDD (area code) belongs to.
    #
    # @param area_code [String, Integer]
    # @return [Hash, nil]
    def self.get_info(area_code)
      return nil if area_code.nil?

      str = area_code.to_s.strip
      return nil unless str.match?(/\A\d+\z/)

      row = load_data.find { |r| r['areaCode'] == str.to_i }
      row && to_symbolized(row)
    end

    # Returns every DDD that serves a state, sorted ascending.
    #
    # @param state_code [String]
    # @return [Array<Integer>]
    def self.list_by_state(state_code)
      return [] unless state_code.is_a?(String)

      normalized = state_code.strip.upcase
      return [] if normalized.empty?

      load_data
        .select { |r| r['stateCodes'].include?(normalized) }
        .map { |r| r['areaCode'] }
        .sort
    end
  end
end
