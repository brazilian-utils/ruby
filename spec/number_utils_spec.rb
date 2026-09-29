require 'spec_helper'

RSpec.describe BrazilianUtils::NumberUtils do
  describe '.convert_to_words' do
    it 'converts 0' do
      expect(described_class.convert_to_words(0)).to eq('zero')
    end

    it 'converts 1' do
      expect(described_class.convert_to_words(1)).to eq('um')
    end

    it 'converts 3' do
      expect(described_class.convert_to_words(3)).to eq('três')
    end

    it 'converts 100' do
      expect(described_class.convert_to_words(100)).to eq('cem')
    end

    it 'converts 101' do
      expect(described_class.convert_to_words(101)).to eq('cento e um')
    end

    it 'converts 123' do
      expect(described_class.convert_to_words(123)).to eq('cento e vinte e três')
    end

    it 'converts 1000' do
      expect(described_class.convert_to_words(1000)).to eq('mil')
    end

    it 'converts 1_000_000' do
      expect(described_class.convert_to_words(1_000_000)).to eq('um milhão')
    end

    it 'converts a negative number' do
      expect(described_class.convert_to_words(-3)).to eq('menos três')
    end

    it 'truncates a fractional value toward zero' do
      expect(described_class.convert_to_words(12.9)).to eq('doze')
    end

    it 'returns an empty string for a value out of range' do
      expect(described_class.convert_to_words(1_000_000_000_000_000)).to eq('')
    end

    it 'returns an empty string for a non-finite value' do
      expect(described_class.convert_to_words(Float::INFINITY)).to eq('')
    end

    it 'returns an empty string for a non-numeric value' do
      expect(described_class.convert_to_words('abc')).to eq('')
    end

    context 'with the feminine gender option' do
      it 'agrees "uma"' do
        expect(described_class.convert_to_words(1, gender: :feminine)).to eq('uma')
      end

      it 'agrees "duas"' do
        expect(described_class.convert_to_words(2, gender: :feminine)).to eq('duas')
      end

      it 'agrees the hundreds' do
        expect(described_class.convert_to_words(200, gender: :feminine)).to eq('duzentas')
      end
    end
  end
end
