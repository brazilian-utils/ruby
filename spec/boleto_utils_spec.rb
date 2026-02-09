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
end
