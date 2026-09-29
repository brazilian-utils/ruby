# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BrazilianUtils::BoletoUtils do
  describe '.is_valid' do
    context 'with valid boleto digitable lines' do
      it 'validates a correct 47-character digitable line' do
        expect(described_class.is_valid('00190000090114971860168524522114675860000102656')).to be true
      end

      it 'validates a digitable line with spaces and dots' do
        expect(described_class.is_valid('0019000009 01149.718601 68524.522114 6 75860000102656')).to be true
      end

      it 'validates multiple valid digitable lines' do
        valid_lines = [
          '00190000090114971860168524522114675860000102656',
          '0019000009 01149.718601 68524.522114 6 75860000102656'
        ]

        valid_lines.each do |line|
          expect(described_class.is_valid(line)).to be true
        end
      end
    end

    context 'with invalid boleto digitable lines' do
      it 'rejects empty string' do
        expect(described_class.is_valid('')).to be false
      end

      it 'rejects strings with insufficient length' do
        expect(described_class.is_valid('000111')).to be false
      end

      it 'rejects digitable lines with invalid first partial check digit' do
        expect(described_class.is_valid('00190000020114971860168524522114675860000102656')).to be false
      end

      it 'rejects digitable lines with invalid mod11 check digit' do
        expect(described_class.is_valid('00190000090114971860168524522114975860000102656')).to be false
      end

      it 'rejects strings with more than 47 numeric characters' do
        expect(described_class.is_valid('001900000901149718601685245221146758600001026560')).to be false
      end

      it 'rejects invalid digitable lines' do
        invalid_lines = [
          '00190000020114971860168524522114675860000102656',
          '00190000090114971860168524522114975860000102656'
        ]

        invalid_lines.each do |line|
          expect(described_class.is_valid(line)).to be false
        end
      end
    end

    context 'with edge cases' do
      it 'rejects nil input' do
        expect(described_class.is_valid(nil)).to be false
      end

      it 'handles strings with various formatting characters' do
        # Valid line with formatting should work
        formatted_line = '00190.00009 01149.718601 68524.522114 6 75860000102656'
        expect(described_class.is_valid(formatted_line)).to be true
      end

      it 'rejects strings with alphabetic characters' do
        expect(described_class.is_valid('0019000009A114971860168524522114675860000102656')).to be false
      end

      it 'handles strings with only formatting characters' do
        expect(described_class.is_valid('... ---')).to be false
      end
    end

    context 'testing mod10 validation' do
      it 'validates all three partial segments correctly' do
        valid_line = '00190000090114971860168524522114675860000102656'
        expect(described_class.is_valid(valid_line)).to be true
      end

      it 'rejects when first partial is invalid' do
        invalid_line = '00190000020114971860168524522114675860000102656'
        expect(described_class.is_valid(invalid_line)).to be false
      end
    end

    context 'testing mod11 validation' do
      it 'validates mod11 check digit correctly' do
        valid_line = '00190000090114971860168524522114675860000102656'
        expect(described_class.is_valid(valid_line)).to be true
      end

      it 'rejects when mod11 check digit is invalid' do
        invalid_line = '00190000090114971860168524522114975860000102656'
        expect(described_class.is_valid(invalid_line)).to be false
      end
    end
  end

  describe '.valid?' do
    it 'is an alias for is_valid' do
      expect(described_class.method(:valid?)).to eq(described_class.method(:is_valid))
    end

    it 'works the same as is_valid' do
      valid_line = '00190000090114971860168524522114675860000102656'
      expect(described_class.valid?(valid_line)).to be true
      expect(described_class.valid?(valid_line)).to eq(described_class.is_valid(valid_line))
    end
  end

  describe '.format' do
    it 'masks a 47-digit cobrança bancária linha digitável' do
      expect(described_class.format('10491443385511900000200000000141325230000093423'))
        .to eq('10491.44338 55119.000002 00000.000141 3 25230000093423')
    end

    it 'masks a partial value as far as it goes' do
      expect(described_class.format('104914')).to eq('10491.4')
    end

    it 'returns an empty string for empty input' do
      expect(described_class.format('')).to eq('')
    end
  end

  describe '.parse' do
    it 'removes the cobrança bancária mask' do
      expect(described_class.parse('10491.44338 55119.000002 00000.000141 3 25230000093423'))
        .to eq('10491443385511900000200000000141325230000093423')
    end

    it 'removes the arrecadação mask (48 digits, leading 8)' do
      expect(described_class.parse('84610000000-5 24610029110-2 00546033900-4 69589506108-0'))
        .to eq('846100000005246100291102005460339004695895061080')
    end

    it 'returns an empty string for empty input' do
      expect(described_class.parse('')).to eq('')
    end
  end

  describe '.generate' do
    it 'generates a 47-digit value that passes .is_valid' do
      10.times do
        line = described_class.generate
        expect(line.length).to eq(47)
        expect(described_class.is_valid(line)).to be true
      end
    end

    it 'returns nil for type: "arrecadacao" (not implemented)' do
      expect(described_class.generate(type: 'arrecadacao')).to be_nil
    end
  end

  describe '.get_info' do
    # NOTE: no acceptance cases were available in the contract for this
    # function; the due-date (fator de vencimento) resolution in
    # particular is unverified against a reference implementation.

    it 'extracts the bank code and amount from a valid boleto' do
      info = described_class.get_info('60757135008571297205909229083648919190488862573')
      expect(info[:bankCode]).to eq('607')
      expect(info[:amount]).to eq(488_862_573)
    end

    it 'returns nil for an invalid boleto' do
      expect(described_class.get_info('00000000000000000000000000000000000000000000000')).to be_nil
    end

    it 'returns nil for an empty string' do
      expect(described_class.get_info('')).to be_nil
    end
  end
end
