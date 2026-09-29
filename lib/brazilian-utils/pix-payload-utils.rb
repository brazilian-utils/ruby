require_relative 'text-utils'
require_relative 'pix-key-utils'

module BrazilianUtils
  # Utilities for the Pix "BR Code" payload: the EMV-derived TLV (tag-
  # length-value) QR code format defined by the Banco Central's Manual de
  # Padrões para Iniciação do Pix.
  module PixPayloadUtils
    PIX_GUI = 'br.gov.bcb.pix'

    # @private
    def self.crc16(str)
      crc = 0xFFFF
      str.each_byte do |byte|
        crc ^= (byte << 8)
        8.times do
          crc = (crc & 0x8000).zero? ? (crc << 1) & 0xFFFF : ((crc << 1) ^ 0x1021) & 0xFFFF
        end
      end
      crc
    end

    private_class_method :crc16

    # Parses a flat TLV string into an ordered list of `[id, value]` pairs.
    #
    # @return [Array<Array(String, String)>, nil] nil when malformed.
    #
    # @private
    def self.parse_tlv(str)
      fields = []
      pos = 0

      while pos < str.length
        return nil if pos + 4 > str.length

        id = str[pos, 2]
        len_str = str[pos + 2, 2]
        return nil unless id.match?(/\A\d{2}\z/) && len_str.match?(/\A\d{2}\z/)

        len = len_str.to_i
        value = str[pos + 4, len]
        return nil if value.nil? || value.length != len

        fields << [id, value]
        pos += 4 + len
      end

      fields
    end

    private_class_method :parse_tlv

    # @private
    def self.find_pix_merchant_account_info(fields)
      fields.each do |id, value|
        next unless ('26'..'51').cover?(id)

        nested = parse_tlv(value)
        next unless nested

        gui = nested.find { |nid, _| nid == '00' }
        next unless gui && gui[1].downcase == PIX_GUI

        return nested
      end
      nil
    end

    private_class_method :find_pix_merchant_account_info

    # @private
    def self.validated_fields(value)
      return nil unless value.is_a?(String) && !value.empty?
      return nil if value.length < 4

      crc_declared = value[-4..-1]
      return nil unless crc_declared.match?(/\A[0-9A-Fa-f]{4}\z/)
      return nil unless format('%04X', crc16(value[0...-4])) == crc_declared.upcase

      fields = parse_tlv(value)
      return nil unless fields
      return nil unless fields.last && fields.last[0] == '63' && fields.last[1].length == 4

      by_id = {}
      fields.each { |id, v| (by_id[id] ||= []) << v }

      return nil unless by_id['00'] == ['01']
      return nil unless by_id['52']&.first&.match?(/\A\d{4}\z/)
      return nil unless by_id['53']&.first
      return nil unless by_id['58']&.first == 'BR'
      return nil unless by_id['59']&.first&.length&.between?(1, 99)
      return nil unless by_id['60']&.first&.length&.between?(1, 99)

      poi = by_id['01']&.first
      return nil if poi && !%w[11 12].include?(poi)

      merchant_account = find_pix_merchant_account_info(fields)
      return nil unless merchant_account

      key_entry = merchant_account.find { |id, _| id == '01' }
      url_entry = merchant_account.find { |id, _| id == '25' }
      return nil if key_entry.nil? == url_entry.nil?

      amount = by_id['54']&.first
      return nil if amount && !(amount.to_f > 0)

      { fields: fields, by_id: by_id, poi: poi, key_entry: key_entry, url_entry: url_entry }
    end

    private_class_method :validated_fields

    # Validates a Pix BR Code payload (the key itself is not checked; use
    # `PixKeyUtils.is_valid`).
    #
    # @param value [String]
    # @return [Boolean]
    def self.is_valid(value)
      !validated_fields(value).nil?
    end

    class << self
      alias valid? is_valid
    end

    # Parses a Pix BR Code payload into its fields.
    #
    # @param value [String]
    # @return [Hash, nil] nil for anything {is_valid} rejects.
    def self.get_info(value)
      parsed = validated_fields(value)
      return nil unless parsed

      by_id = parsed[:by_id]
      has_psp_location = !parsed[:url_entry].nil?
      point_of_initiation = (parsed[:poi] == '12' || has_psp_location) ? 'dynamic' : 'static'

      info = {
        merchantName: by_id['59'].first,
        merchantCity: by_id['60'].first,
        pointOfInitiation: point_of_initiation
      }

      if has_psp_location
        info[:url] = parsed[:url_entry][1]
      else
        info[:key] = parsed[:key_entry][1]

        unless has_psp_location
          amount = by_id['54']&.first
          info[:amount] = amount.to_f if amount

          additional = by_id['62']&.first
          if additional
            nested = parse_tlv(additional)
            txid_entry = nested&.find { |id, _| id == '05' }
            info[:txid] = txid_entry[1] if txid_entry && txid_entry[1] != '***'
          end
        end
      end

      info
    end

    # @private
    def self.tlv(id, value)
      "#{id}#{value.length.to_s.rjust(2, '0')}#{value}"
    end

    private_class_method :tlv

    # Generates a Pix BR Code payload.
    #
    # @param params [Hash] Exactly one of `:key` (static) or `:url`
    #   (dynamic) must be given, plus `:merchantName` and `:merchantCity`,
    #   and optionally `:amount`, `:txid` and `:description`.
    # @return [String, nil] nil when the parameters are invalid or
    #   contradictory (e.g. both/neither `:key` and `:url` given).
    #
    # @note This has no acceptance test cases in the contract; it has only
    #   been self-verified (a generated payload passes {is_valid} and
    #   round-trips through {get_info}), not cross-checked against a
    #   reference implementation's own test suite.
    def self.generate(params)
      return nil unless params.is_a?(Hash)

      key = params[:key] || params['key']
      url = params[:url] || params['url']
      return nil if key.nil? == url.nil?

      merchant_name = params[:merchantName] || params['merchantName']
      merchant_city = params[:merchantCity] || params['merchantCity']
      return nil unless merchant_name.is_a?(String) && merchant_city.is_a?(String)
      return nil if merchant_name.empty? || merchant_city.empty?

      amount = params[:amount] || params['amount']
      txid = params[:txid] || params['txid'] || '***'
      description = params[:description] || params['description']

      clean_url = nil
      key_info = nil

      if url
        return nil unless url.is_a?(String)
        return nil if amount || (params[:txid] || params['txid'])

        clean_url = url.sub(%r{\Ahttps?://}, '')
        return nil if clean_url.empty? || clean_url.length > 77
      else
        key_info = PixKeyUtils.get_info(key)
        return nil unless key_info
      end

      amount_str = nil
      if amount
        return nil if amount.to_s.match?(/\.\d{3,}/)

        amount_str = format('%.2f', amount.to_f)
        return nil unless amount_str.to_f.positive?
      end

      return nil unless txid == '***' || txid.match?(/\A[A-Za-z0-9]{1,25}\z/)

      name = TextUtils.remove_accents(merchant_name)[0, 25]
      city = TextUtils.remove_accents(merchant_city)[0, 15]

      merchant_account_value = tlv('00', PIX_GUI) + (url ? tlv('25', clean_url) : tlv('01', key_info[:value]))

      fields = []
      fields << tlv('00', '01')
      fields << tlv('01', url ? '12' : '11')
      fields << tlv('26', merchant_account_value)
      fields << tlv('52', '0000')
      fields << tlv('53', '986')
      fields << tlv('54', amount_str) if amount_str && !url
      fields << tlv('58', 'BR')
      fields << tlv('59', name)
      fields << tlv('60', city)

      unless url
        additional = tlv('05', txid)
        if description
          desc = TextUtils.remove_accents(description)[0, 99]
          additional += tlv('02', desc) unless desc.empty?
        end
        fields << tlv('62', additional)
      end

      payload_without_crc = fields.join + '6304'
      payload_without_crc + format('%04X', crc16(payload_without_crc))
    end
  end
end
