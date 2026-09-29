require 'spec_helper'

RSpec.describe BrazilianUtils::PixPayloadUtils do
  STATIC_EXAMPLE = '00020126580014br.gov.bcb.pix0136123e4567-e12b-12d1-a456-' \
                   '4266554400005204000053039865802BR5913Fulano de Tal6008BRASILIA' \
                   '62070503***63041D3D'.freeze

  WITH_AMOUNT_EXAMPLE = '00020126580014br.gov.bcb.pix0136bee05743-4291-4f3c-9259-' \
                        '595df1307ba1520400005303986540510.005802BR5914Alexandre Lima' \
                        '6019Presidente Prudente62180514Um-Id-Qualquer6304D475'.freeze

  WRONG_CRC_EXAMPLE = '00020126580014br.gov.bcb.pix0136123e4567-e12b-12d1-a456-' \
                       '4266554400005204000053039865802BR5913Fulano de Tal6008BRASILIA' \
                       '62070503***63041D3E'.freeze

  describe '.is_valid' do
    it 'validates the Bacen static example' do
      expect(described_class.is_valid(STATIC_EXAMPLE)).to be true
    end

    it 'validates a payload with an amount and a txid' do
      expect(described_class.is_valid(WITH_AMOUNT_EXAMPLE)).to be true
    end

    it 'rejects a payload with a wrong CRC' do
      expect(described_class.is_valid(WRONG_CRC_EXAMPLE)).to be false
    end

    it 'rejects an empty string' do
      expect(described_class.is_valid('')).to be false
    end
  end

  describe '.get_info' do
    it 'parses the Bacen static example' do
      expect(described_class.get_info(STATIC_EXAMPLE)).to eq(
        key: '123e4567-e12b-12d1-a456-426655440000',
        merchantName: 'Fulano de Tal',
        merchantCity: 'BRASILIA',
        pointOfInitiation: 'static'
      )
    end

    it 'parses a payload with an amount and a txid' do
      expect(described_class.get_info(WITH_AMOUNT_EXAMPLE)).to eq(
        key: 'bee05743-4291-4f3c-9259-595df1307ba1',
        merchantName: 'Alexandre Lima',
        merchantCity: 'Presidente Prudente',
        amount: 10.0,
        txid: 'Um-Id-Qualquer',
        pointOfInitiation: 'static'
      )
    end

    it 'returns nil for a wrong CRC' do
      expect(described_class.get_info(WRONG_CRC_EXAMPLE)).to be_nil
    end

    it 'returns nil for an empty string' do
      expect(described_class.get_info('')).to be_nil
    end
  end

  describe '.generate' do
    # NOTE: no acceptance cases were available in the contract for this
    # function; these specs only check that a generated payload is
    # internally consistent (passes .is_valid and round-trips through
    # .get_info), not that it matches a reference implementation byte for
    # byte.

    it 'generates a valid static payload from a key' do
      payload = described_class.generate(
        key: '123.456.789-09', merchantName: 'Fulano de Tal', merchantCity: 'Brasília',
        amount: 10.5, txid: 'abc123'
      )
      expect(described_class.is_valid(payload)).to be true
      expect(described_class.get_info(payload)).to eq(
        merchantName: 'Fulano de Tal', merchantCity: 'Brasilia',
        pointOfInitiation: 'static', key: '12345678909', amount: 10.5, txid: 'abc123'
      )
    end

    it 'generates a valid dynamic payload from a URL' do
      payload = described_class.generate(
        url: 'pix.example.com/qr/v2/abc123', merchantName: 'Loja Teste', merchantCity: 'Sao Paulo'
      )
      expect(described_class.is_valid(payload)).to be true
      expect(described_class.get_info(payload)).to eq(
        merchantName: 'Loja Teste', merchantCity: 'Sao Paulo',
        pointOfInitiation: 'dynamic', url: 'pix.example.com/qr/v2/abc123'
      )
    end

    it 'defaults the txid to the *** marker (no txid) when omitted' do
      payload = described_class.generate(key: '123.456.789-09', merchantName: 'Fulano', merchantCity: 'Brasilia')
      expect(described_class.is_valid(payload)).to be true
      expect(described_class.get_info(payload)[:txid]).to be_nil
    end

    it 'returns nil when neither key nor url is given' do
      expect(described_class.generate(merchantName: 'x', merchantCity: 'y')).to be_nil
    end

    it 'returns nil when both key and url are given' do
      expect(described_class.generate(key: '123.456.789-09', url: 'x', merchantName: 'a', merchantCity: 'b')).to be_nil
    end

    it 'returns nil for an invalid key' do
      expect(described_class.generate(key: 'not-a-key', merchantName: 'a', merchantCity: 'b')).to be_nil
    end
  end
end
