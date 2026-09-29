require 'spec_helper'

RSpec.describe BrazilianUtils::CertidaoUtils do
  describe '.format' do
    it 'groups a 32-digit matrícula' do
      expect(described_class.format('10453901552013100012021000012321'))
        .to eq('104539 01 55 2013 1 00012 021 0000123 21')
    end

    it 're-masks an already-formatted matrícula' do
      expect(described_class.format('104539.01.55.2013.1.00012.021.0000123-21'))
        .to eq('104539 01 55 2013 1 00012 021 0000123 21')
    end

    it 'masks a partial value as far as it goes' do
      expect(described_class.format('10453901')).to eq('104539 01')
    end

    it 'returns an empty string for empty input' do
      expect(described_class.format('')).to eq('')
    end
  end

  describe '.parse' do
    it 'removes the mask' do
      expect(described_class.parse('104539 01 55 2013 1 00012 021 0000123 21'))
        .to eq('10453901552013100012021000012321')
    end

    it 'strips non-digit characters' do
      expect(described_class.parse('104539.01.55.2013.1.00012.021.0000123-21abc'))
        .to eq('10453901552013100012021000012321')
    end

    it 'caps the result to 32 characters' do
      expect(described_class.parse('10453901552013100012021000012321999'))
        .to eq('10453901552013100012021000012321')
    end

    it 'returns an empty string for empty input' do
      expect(described_class.parse('')).to eq('')
    end
  end

  # Check-digit algorithm: matrícula is 32 digits, grouped 6-2-2-4-1-5-3-7-2.
  # Over the 30-digit base, dv1 is a modulus-11 check digit with weight 2
  # starting at the rightmost digit and increasing by 1 moving left (no cap,
  # no wraparound); dv2 is computed the same way over the base plus dv1.
  #
  # All three of the contract's worked examples are used verbatim below and
  # reproduce under this algorithm (base30 -> "21", "87" and "43" check
  # digits respectively) — confirmed by running the actual is_valid/get_info
  # code against each one directly.
  describe '.is_valid' do
    it 'accepts the first worked example (unmasked)' do
      expect(described_class.is_valid('10453901552013100012021000012321')).to be true
    end

    it 'accepts the first worked example (space-masked)' do
      expect(described_class.is_valid('104539 01 55 2013 1 00012 021 0000123 21')).to be true
    end

    it 'accepts the second worked example (unmasked)' do
      expect(described_class.is_valid('09430001552010100020112000012087')).to be true
    end

    it 'accepts the second worked example (space-masked)' do
      expect(described_class.is_valid('094300 01 55 2010 1 00020 112 0000120-87')).to be true
    end

    it 'accepts the third worked example (unmasked)' do
      expect(described_class.is_valid('09400301552011100110002005191743')).to be true
    end

    it 'accepts a slash-separated masked value' do
      expect(described_class.is_valid('104539/01/55/2013/1/00012/021/0000123/21')).to be true
    end

    it 'accepts a dot/dash-separated masked value' do
      expect(described_class.is_valid('104539.01.55.2013.1.00012.021.0000123-21')).to be true
    end

    it 'rejects wrong check digits' do
      expect(described_class.is_valid('10453901552013100012021000012399')).to be false
    end

    it 'rejects a value that is too short' do
      expect(described_class.is_valid('104539015520131000120210000123')).to be false
    end

    it 'rejects empty input' do
      expect(described_class.is_valid('')).to be false
    end

    it 'rejects a value containing a stray letter' do
      expect(described_class.is_valid('1045390155201310001202100001a321')).to be false
    end
  end

  describe '.valid?' do
    it 'is an alias for is_valid' do
      expect(described_class.valid?('10453901552013100012021000012321')).to be true
    end
  end

  describe '.get_info' do
    it 'returns the field breakdown for a valid matrícula' do
      expect(described_class.get_info('10453901552013100012021000012321')).to eq(
        registryCns: '104539',
        acervo: '01',
        service: '55',
        year: 2013,
        type: 'birth',
        book: '00012',
        page: '021',
        term: '0000123',
        checkDigits: '21'
      )
    end

    it 'returns the field breakdown for the second worked example' do
      expect(described_class.get_info('094300 01 55 2010 1 00020 112 0000120-87')).to eq(
        registryCns: '094300',
        acervo: '01',
        service: '55',
        year: 2010,
        type: 'birth',
        book: '00020',
        page: '112',
        term: '0000120',
        checkDigits: '87'
      )
    end

    it 'returns nil for an invalid matrícula' do
      expect(described_class.get_info('10453901552013100012021000012399')).to be_nil
    end
  end
end
