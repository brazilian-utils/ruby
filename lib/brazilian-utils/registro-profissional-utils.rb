module BrazilianUtils
  # Utilities for checking the *structure* of a professional council
  # registration number (OAB, CRM, CRO, CRP or CRC). This never validates a
  # check digit — none of these councils publish one — only the digit
  # count and the UF.
  #
  # @note There were no acceptance test cases available in the contract for
  #   this function; this implementation follows the prose description as
  #   closely as possible but has not been cross-checked against a
  #   reference implementation's test suite.
  module RegistroProfissionalUtils
    UFS = %w[
      AC AL AP AM BA CE DF ES GO MA MT MS MG PA PB PR PE PI RJ RN RS RO RR SC SP SE TO
    ].freeze

    # Checks the structure of a professional council registration number.
    #
    # @param params [Hash] `:value` (the registration string), `:council`
    #   (`"OAB"`, `"CRM"`, `"CRO"`, `"CRP"` or `"CRC"`) and an optional
    #   `:state` (the expected UF).
    # @return [Boolean]
    def self.is_valid(params)
      return false unless params.is_a?(Hash)

      value = params[:value] || params['value']
      council = (params[:council] || params['council']).to_s.upcase
      expected_state = params[:state] || params['state']

      return false unless value.is_a?(String)

      case council
      when 'OAB', 'CRM'
        valid_oab_crm?(value, expected_state)
      when 'CRO'
        valid_cro?(value, expected_state)
      when 'CRP'
        valid_crp?(value)
      when 'CRC'
        valid_crc?(value, expected_state)
      else
        false
      end
    end

    class << self
      alias valid? is_valid
    end

    # @private
    def self.matches_expected_state?(uf, expected_state)
      expected_state.nil? || expected_state.to_s.upcase == uf
    end

    private_class_method :matches_expected_state?

    # OAB and CRM: 4 to 6 digits plus the UF (`123456/SP`, `123456-SP`).
    #
    # @private
    def self.valid_oab_crm?(value, expected_state)
      m = value.strip.match(%r{\A(\d{4,6})[/-]([A-Za-z]{2})\z})
      return false unless m

      uf = m[2].upcase
      UFS.include?(uf) && matches_expected_state?(uf, expected_state)
    end

    private_class_method :valid_oab_crm?

    # CRO: 3 to 6 digits plus the UF.
    #
    # @private
    def self.valid_cro?(value, expected_state)
      m = value.strip.match(%r{\A(\d{3,6})[/-]([A-Za-z]{2})\z})
      return false unless m

      uf = m[2].upcase
      UFS.include?(uf) && matches_expected_state?(uf, expected_state)
    end

    private_class_method :valid_cro?

    # CRP: a 2-digit regional code (01-24) plus 4 to 6 digits
    # (`06/12345`); the expected state is ignored.
    #
    # @private
    def self.valid_crp?(value)
      m = value.strip.match(%r{\A(\d{2})[/-](\d{4,6})\z})
      return false unless m

      m[1].to_i.between?(1, 24)
    end

    private_class_method :valid_crp?

    # CRC: UF, 6 digits, registration type (`O` or `P`) and a digit
    # (`SP-123456/O-3`), optionally a transfer suffix (`T-MG` or `S-MG`).
    #
    # @private
    def self.valid_crc?(value, expected_state)
      m = value.strip.match(%r{\A([A-Za-z]{2})-(\d{6})/([OoPp])-(\d)(?:\s+[TtSs]-([A-Za-z]{2}))?\z})
      return false unless m

      uf = m[1].upcase
      return false unless UFS.include?(uf)
      return false if m[5] && !UFS.include?(m[5].upcase)

      matches_expected_state?(uf, expected_state)
    end

    private_class_method :valid_crc?
  end
end
