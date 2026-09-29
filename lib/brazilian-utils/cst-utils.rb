require 'json'

module BrazilianUtils
  # Utilities for the CST (Código de Situação Tributária) tables: ICMS
  # (Tabela A "origem" + Tabela B "tributação"), IPI and PIS/COFINS (which
  # share a table).
  module CSTUtils
    DATA_FILE = File.join(File.dirname(__FILE__), 'data', 'cst.json')

    # @private
    def self.load_data
      @data ||= JSON.parse(File.read(DATA_FILE))
    end

    private_class_method :load_data

    # @private
    def self.icms_origins
      load_data['icmsOrigin']['entries'].map { |e| e['code'] }
    end

    # @private
    def self.icms_csts
      load_data['icmsCst']['entries'].map { |e| e['code'] }
    end

    # @private
    def self.ipi_csts
      load_data['ipiCst']['entries'].map { |e| e['code'] }
    end

    # @private
    def self.pis_cofins_csts
      load_data['pisCofinsCst']['entries'].map { |e| e['code'] }
    end

    private_class_method :icms_origins, :icms_csts, :ipi_csts, :pis_cofins_csts

    # Checks whether a CST code is valid for a tax.
    #
    # @param value [String, Integer] A string or a non-negative integer. The
    #   3-digit ICMS form (origin + Tabela B code) may have a single
    #   separator right after the origin digit (e.g. `"1-10"`). A single
    #   digit is padded to the 3-digit ICMS form; a 2-digit string is
    #   checked as a Tabela B / IPI / PIS-COFINS code.
    # @param options [Hash] `:tax` picks the table: `"icms"`, `"ipi"`,
    #   `"pis"` or `"cofins"` (PIS and COFINS share a table). Omitted or
    #   unknown, every table is accepted.
    # @return [Boolean]
    def self.is_valid(value, options = {})
      return false if value.nil?

      tax = (options[:tax] || options['tax']).to_s.downcase
      tax = nil if tax.empty? || !%w[icms ipi pis cofins].include?(tax)

      raw = value.to_s.strip
      return false if raw.empty?

      three_digit, two_digit = normalize(raw)

      icms_ok = !three_digit.nil? && icms_origins.include?(three_digit[0]) && icms_csts.include?(three_digit[1, 2])

      case tax
      when 'icms'
        icms_ok
      when 'ipi'
        !two_digit.nil? && ipi_csts.include?(two_digit)
      when 'pis', 'cofins'
        !two_digit.nil? && pis_cofins_csts.include?(two_digit)
      else
        icms_ok ||
          (!two_digit.nil? && (icms_csts.include?(two_digit) || ipi_csts.include?(two_digit) || pis_cofins_csts.include?(two_digit)))
      end
    end

    class << self
      alias valid? is_valid
    end

    # Normalizes a raw CST value into a candidate 3-digit ICMS form and/or a
    # candidate 2-digit (Tabela B / IPI / PIS-COFINS) form.
    #
    # @return [Array(String, nil), Array(nil, String), Array(nil, nil)]
    #
    # @private
    def self.normalize(raw)
      case raw
      when /\A\d\z/
        [raw.rjust(3, '0'), nil]
      when /\A\d{3}\z/
        [raw, nil]
      when /\A\d[-.]\d{2}\z/
        [raw[0] + raw[2, 2], nil]
      when /\A\d{2}\z/
        [nil, raw]
      else
        [nil, nil]
      end
    end

    private_class_method :normalize
  end
end
