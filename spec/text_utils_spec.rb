require 'spec_helper'

RSpec.describe BrazilianUtils::TextUtils do
  describe '.capitalize' do
    it 'capitalizes each word' do
      expect(described_class.capitalize('esponja vegetal')).to eq('Esponja Vegetal')
    end

    it 'downcases an all-uppercase name, keeping accents' do
      expect(described_class.capitalize('JOAQUIM JOSÉ')).to eq('Joaquim José')
    end

    it 'lower-cases a preposition between two words' do
      expect(described_class.capitalize('fulano de tal')).to eq('Fulano de Tal')
    end

    it 'collapses whitespace runs and lowercases a trailing unit suffix' do
      expect(described_class.capitalize('esponja de    aço 60G')).to eq('Esponja de Aço 60g')
    end

    it 'capitalizes a preposition when it is the only (first and last) word' do
      expect(described_class.capitalize('de')).to eq('De')
    end

    it 'returns an empty string for empty input' do
      expect(described_class.capitalize('')).to eq('')
    end

    it 'returns an empty string for non-string input' do
      expect(described_class.capitalize(nil)).to eq('')
    end

    it 'supports a feminine gender-agreed custom designation list' do
      expect(described_class.capitalize('empresa ltda', designations: %w[LTDA])).to eq('Empresa LTDA')
    end
  end

  describe '.remove_accents' do
    it 'removes a tilde' do
      expect(described_class.remove_accents('São Paulo')).to eq('Sao Paulo')
    end

    it 'removes a cedilla and an acute accent' do
      expect(described_class.remove_accents('Açaí')).to eq('Acai')
    end

    it 'removes an acute accent on an i' do
      expect(described_class.remove_accents('Piauí')).to eq('Piaui')
    end

    it 'leaves a string with no accents unchanged' do
      expect(described_class.remove_accents('Brasil')).to eq('Brasil')
    end

    it 'keeps punctuation' do
      expect(described_class.remove_accents('São Paulo, SP - 2024!')).to eq('Sao Paulo, SP - 2024!')
    end

    it 'returns an empty string for empty input' do
      expect(described_class.remove_accents('')).to eq('')
    end

    it 'returns an empty string for non-string input' do
      expect(described_class.remove_accents(nil)).to eq('')
    end
  end
end
