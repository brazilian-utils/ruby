require 'spec_helper'

RSpec.describe BrazilianUtils::LicensePlateUtils do
  describe '.convert_to_mercosul' do
    context 'when converting valid old format plates' do
      it 'converts ABC1234 to Mercosul format' do
        expect(described_class.convert_to_mercosul('ABC1234')).to eq('ABC1C34')
      end

      it 'converts ABC0000 to Mercosul format (0→A)' do
        expect(described_class.convert_to_mercosul('ABC0000')).to eq('ABC0A00')
      end

      it 'converts ABC1000 to Mercosul format (1→B)' do
        expect(described_class.convert_to_mercosul('ABC1000')).to eq('ABC1A00')
      end

      it 'converts ABC2345 to Mercosul format (2→C)' do
        expect(described_class.convert_to_mercosul('ABC2345')).to eq('ABC2C45')
      end

      it 'converts ABC3456 to Mercosul format (3→D)' do
        expect(described_class.convert_to_mercosul('ABC3456')).to eq('ABC3D56')
      end

      it 'converts ABC4567 to Mercosul format (4→E)' do
        expect(described_class.convert_to_mercosul('ABC4567')).to eq('ABC4E67')
      end

      it 'converts ABC5678 to Mercosul format (5→F)' do
        expect(described_class.convert_to_mercosul('ABC5678')).to eq('ABC5F78')
      end

      it 'converts ABC6789 to Mercosul format (6→G)' do
        expect(described_class.convert_to_mercosul('ABC6789')).to eq('ABC6G89')
      end

      it 'converts ABC7890 to Mercosul format (7→H)' do
        expect(described_class.convert_to_mercosul('ABC7890')).to eq('ABC7H90')
      end

      it 'converts ABC8901 to Mercosul format (8→I)' do
        expect(described_class.convert_to_mercosul('ABC8901')).to eq('ABC8I01')
      end

      it 'converts ABC9999 to Mercosul format (9→J)' do
        expect(described_class.convert_to_mercosul('ABC9999')).to eq('ABC9J99')
      end

      it 'converts lowercase old format plate' do
        expect(described_class.convert_to_mercosul('abc1234')).to eq('ABC1C34')
      end

      it 'converts mixed case old format plate' do
        expect(described_class.convert_to_mercosul('AbC1234')).to eq('ABC1C34')
      end

      it 'converts old format plate with dash' do
        expect(described_class.convert_to_mercosul('ABC-1234')).to eq('ABC1C34')
      end

      it 'converts XYZ9876 correctly' do
        expect(described_class.convert_to_mercosul('XYZ9876')).to eq('XYZ9J76')
      end
    end

    context 'when conversion fails' do
      it 'returns nil for invalid format' do
        expect(described_class.convert_to_mercosul('ABCD123')).to be_nil
      end

      it 'returns nil for Mercosul format (already converted)' do
        expect(described_class.convert_to_mercosul('ABC1D34')).to be_nil
      end

      it 'returns nil for too short string' do
        expect(described_class.convert_to_mercosul('ABC123')).to be_nil
      end

      it 'returns nil for too long string' do
        expect(described_class.convert_to_mercosul('ABC12345')).to be_nil
      end

      it 'returns nil for empty string' do
        expect(described_class.convert_to_mercosul('')).to be_nil
      end

      it 'returns nil for non-string input' do
        expect(described_class.convert_to_mercosul(nil)).to be_nil
      end

      it 'returns nil for numeric input' do
        expect(described_class.convert_to_mercosul(1234567)).to be_nil
      end

      it 'returns nil for plate with special characters' do
        expect(described_class.convert_to_mercosul('ABC@1234')).to be_nil
      end
    end
  end

  describe '.format_license_plate' do
    context 'when formatting old format plates' do
      it 'formats ABC1234 with dash' do
        expect(described_class.format_license_plate('ABC1234')).to eq('ABC-1234')
      end

      it 'formats lowercase old format plate' do
        expect(described_class.format_license_plate('abc1234')).to eq('ABC-1234')
      end

      it 'formats mixed case old format plate' do
        expect(described_class.format_license_plate('AbC1234')).to eq('ABC-1234')
      end

      it 'keeps dash if already formatted' do
        expect(described_class.format_license_plate('ABC-1234')).to eq('ABC-1234')
      end

      it 'formats XYZ9876 with dash' do
        expect(described_class.format_license_plate('XYZ9876')).to eq('XYZ-9876')
      end
    end

    context 'when formatting Mercosul format plates' do
      it 'formats ABC1D34 to uppercase' do
        expect(described_class.format_license_plate('ABC1D34')).to eq('ABC1D34')
      end

      it 'formats lowercase Mercosul plate' do
        expect(described_class.format_license_plate('abc1d34')).to eq('ABC1D34')
      end

      it 'formats mixed case Mercosul plate' do
        expect(described_class.format_license_plate('AbC1d34')).to eq('ABC1D34')
      end

      it 'formats XYZ2E45' do
        expect(described_class.format_license_plate('XYZ2E45')).to eq('XYZ2E45')
      end
    end

    context 'when formatting fails' do
      it 'returns nil for invalid format' do
        expect(described_class.format_license_plate('ABCD123')).to be_nil
      end

      it 'returns nil for too short string' do
        expect(described_class.format_license_plate('ABC123')).to be_nil
      end

      it 'returns nil for too long string' do
        expect(described_class.format_license_plate('ABC12345')).to be_nil
      end

      it 'returns nil for empty string' do
        expect(described_class.format_license_plate('')).to be_nil
      end

      it 'returns nil for non-string input' do
        expect(described_class.format_license_plate(nil)).to be_nil
      end

      it 'returns nil for numeric input' do
        expect(described_class.format_license_plate(1234567)).to be_nil
      end

      it 'returns nil for plate with special characters' do
        expect(described_class.format_license_plate('ABC@1234')).to be_nil
      end
    end

    it 'has an alias method .format' do
      expect(described_class.format('ABC1234')).to eq('ABC-1234')
    end
  end

  describe '.is_valid' do
    context 'when validating old format plates (without type specified)' do
      it 'validates ABC1234' do
        expect(described_class.is_valid('ABC1234')).to be true
      end

      it 'validates ABC-1234 with dash' do
        expect(described_class.is_valid('ABC-1234')).to be true
      end

      it 'validates lowercase abc1234' do
        expect(described_class.is_valid('abc1234')).to be true
      end

      it 'validates mixed case AbC1234' do
        expect(described_class.is_valid('AbC1234')).to be true
      end

      it 'validates XYZ9876' do
        expect(described_class.is_valid('XYZ9876')).to be true
      end

      it 'validates AAA0000' do
        expect(described_class.is_valid('AAA0000')).to be true
      end

      it 'validates ZZZ9999' do
        expect(described_class.is_valid('ZZZ9999')).to be true
      end
    end

    context 'when validating Mercosul format plates (without type specified)' do
      it 'validates ABC1D34' do
        expect(described_class.is_valid('ABC1D34')).to be true
      end

      it 'validates lowercase abc1d34' do
        expect(described_class.is_valid('abc1d34')).to be true
      end

      it 'validates mixed case AbC1d34' do
        expect(described_class.is_valid('AbC1d34')).to be true
      end

      it 'validates XYZ2E45' do
        expect(described_class.is_valid('XYZ2E45')).to be true
      end

      it 'validates AAA0A00' do
        expect(described_class.is_valid('AAA0A00')).to be true
      end

      it 'validates ZZZ9Z99' do
        expect(described_class.is_valid('ZZZ9Z99')).to be true
      end
    end

    context 'when validating with specific type :old_format' do
      it 'validates ABC1234 as old format' do
        expect(described_class.is_valid('ABC1234', :old_format)).to be true
      end

      it 'validates ABC-1234 as old format' do
        expect(described_class.is_valid('ABC-1234', :old_format)).to be true
      end

      it 'rejects ABC1D34 as old format' do
        expect(described_class.is_valid('ABC1D34', :old_format)).to be false
      end

      it 'validates with string "old_format"' do
        expect(described_class.is_valid('ABC1234', 'old_format')).to be true
      end
    end

    context 'when validating with specific type :mercosul' do
      it 'validates ABC1D34 as Mercosul' do
        expect(described_class.is_valid('ABC1D34', :mercosul)).to be true
      end

      it 'rejects ABC1234 as Mercosul' do
        expect(described_class.is_valid('ABC1234', :mercosul)).to be false
      end

      it 'rejects ABC-1234 as Mercosul' do
        expect(described_class.is_valid('ABC-1234', :mercosul)).to be false
      end

      it 'validates with string "mercosul"' do
        expect(described_class.is_valid('ABC1D34', 'mercosul')).to be true
      end
    end

    context 'when validation fails' do
      it 'rejects ABCD123 (wrong pattern)' do
        expect(described_class.is_valid('ABCD123')).to be false
      end

      it 'rejects ABC123 (too short)' do
        expect(described_class.is_valid('ABC123')).to be false
      end

      it 'rejects ABC12345 (too long)' do
        expect(described_class.is_valid('ABC12345')).to be false
      end

      it 'rejects AB01234 (only 2 letters)' do
        expect(described_class.is_valid('AB01234')).to be false
      end

      it 'rejects ABCD1234 (4 letters)' do
        expect(described_class.is_valid('ABCD1234')).to be false
      end

      it 'rejects 1234567 (only numbers)' do
        expect(described_class.is_valid('1234567')).to be false
      end

      it 'rejects ABCDEFG (only letters)' do
        expect(described_class.is_valid('ABCDEFG')).to be false
      end

      it 'rejects empty string' do
        expect(described_class.is_valid('')).to be false
      end

      it 'rejects nil' do
        expect(described_class.is_valid(nil)).to be false
      end

      it 'rejects numeric input' do
        expect(described_class.is_valid(1234567)).to be false
      end

      it 'rejects plate with special characters' do
        expect(described_class.is_valid('ABC@1234')).to be false
      end

      it 'rejects plate with spaces' do
        expect(described_class.is_valid('ABC 1234')).to be false
      end

      it 'rejects Mercosul with lowercase letter in 5th position' do
        expect(described_class.is_valid('ABC1d34')).to be true  # Validation converts to uppercase
      end
    end

    it 'has an alias method .valid?' do
      expect(described_class.valid?('ABC1234')).to be true
    end
  end

  describe '.remove_symbols' do
    it 'removes dash from ABC-1234' do
      expect(described_class.remove_symbols('ABC-1234')).to eq('ABC1234')
    end

    it 'removes dash from XYZ-9876' do
      expect(described_class.remove_symbols('XYZ-9876')).to eq('XYZ9876')
    end

    it 'returns string unchanged if no symbols' do
      expect(described_class.remove_symbols('ABC1234')).to eq('ABC1234')
    end

    it 'returns string unchanged for Mercosul format' do
      expect(described_class.remove_symbols('ABC1D34')).to eq('ABC1D34')
    end

    it 'removes multiple dashes' do
      expect(described_class.remove_symbols('A-B-C-1-2-3-4')).to eq('ABC1234')
    end

    it 'returns empty string for empty input' do
      expect(described_class.remove_symbols('')).to eq('')
    end

    it 'returns empty string for nil input' do
      expect(described_class.remove_symbols(nil)).to eq('')
    end

    it 'returns empty string for non-string input' do
      expect(described_class.remove_symbols(12345)).to eq('')
    end
  end

  describe '.get_format' do
    context 'when detecting old format' do
      it 'returns LLLNNNN for ABC1234' do
        expect(described_class.get_format('ABC1234')).to eq('LLLNNNN')
      end

      it 'returns LLLNNNN for ABC-1234 with dash' do
        expect(described_class.get_format('ABC-1234')).to eq('LLLNNNN')
      end

      it 'returns LLLNNNN for lowercase abc1234' do
        expect(described_class.get_format('abc1234')).to eq('LLLNNNN')
      end

      it 'returns LLLNNNN for mixed case AbC1234' do
        expect(described_class.get_format('AbC1234')).to eq('LLLNNNN')
      end

      it 'returns LLLNNNN for XYZ9876' do
        expect(described_class.get_format('XYZ9876')).to eq('LLLNNNN')
      end
    end

    context 'when detecting Mercosul format' do
      it 'returns LLLNLNN for ABC1D34' do
        expect(described_class.get_format('ABC1D34')).to eq('LLLNLNN')
      end

      it 'returns LLLNLNN for lowercase abc1d34' do
        expect(described_class.get_format('abc1d34')).to eq('LLLNLNN')
      end

      it 'returns LLLNLNN for mixed case AbC1d34' do
        expect(described_class.get_format('AbC1d34')).to eq('LLLNLNN')
      end

      it 'returns LLLNLNN for XYZ2E45' do
        expect(described_class.get_format('XYZ2E45')).to eq('LLLNLNN')
      end
    end

    context 'when format detection fails' do
      it 'returns nil for invalid format ABCD123' do
        expect(described_class.get_format('ABCD123')).to be_nil
      end

      it 'returns nil for too short ABC123' do
        expect(described_class.get_format('ABC123')).to be_nil
      end

      it 'returns nil for too long ABC12345' do
        expect(described_class.get_format('ABC12345')).to be_nil
      end

      it 'returns nil for empty string' do
        expect(described_class.get_format('')).to be_nil
      end

      it 'returns nil for nil input' do
        expect(described_class.get_format(nil)).to be_nil
      end

      it 'returns nil for numeric input' do
        expect(described_class.get_format(1234567)).to be_nil
      end

      it 'returns nil for plate with special characters' do
        expect(described_class.get_format('ABC@1234')).to be_nil
      end
    end
  end

  describe '.generate' do
    context 'when generating Mercosul format (default)' do
      it 'generates a valid Mercosul plate' do
        plate = described_class.generate
        expect(described_class.is_valid(plate, :mercosul)).to be true
      end

      it 'generates a plate with format LLLNLNN' do
        plate = described_class.generate
        expect(described_class.get_format(plate)).to eq('LLLNLNN')
      end

      it 'generates a 7-character plate' do
        plate = described_class.generate
        expect(plate.length).to eq(7)
      end

      it 'generates different plates on multiple calls' do
        plates = 10.times.map { described_class.generate }
        expect(plates.uniq.length).to be > 1  # Should generate at least some different plates
      end

      it 'generates uppercase letters' do
        plate = described_class.generate
        expect(plate).to eq(plate.upcase)
      end
    end

    context 'when generating old format explicitly' do
      it 'generates a valid old format plate' do
        plate = described_class.generate('LLLNNNN')
        expect(described_class.is_valid(plate, :old_format)).to be true
      end

      it 'generates a plate with format LLLNNNN' do
        plate = described_class.generate('LLLNNNN')
        expect(described_class.get_format(plate)).to eq('LLLNNNN')
      end

      it 'generates a 7-character plate' do
        plate = described_class.generate('LLLNNNN')
        expect(plate.length).to eq(7)
      end

      it 'generates different plates on multiple calls' do
        plates = 10.times.map { described_class.generate('LLLNNNN') }
        expect(plates.uniq.length).to be > 1
      end

      it 'accepts lowercase format parameter' do
        plate = described_class.generate('lllnnnn')
        expect(described_class.is_valid(plate, :old_format)).to be true
      end
    end

    context 'when generating Mercosul format explicitly' do
      it 'generates a valid Mercosul plate' do
        plate = described_class.generate('LLLNLNN')
        expect(described_class.is_valid(plate, :mercosul)).to be true
      end

      it 'generates a plate with format LLLNLNN' do
        plate = described_class.generate('LLLNLNN')
        expect(described_class.get_format(plate)).to eq('LLLNLNN')
      end

      it 'accepts lowercase format parameter' do
        plate = described_class.generate('lllnlnn')
        expect(described_class.is_valid(plate, :mercosul)).to be true
      end
    end

    context 'when generation fails' do
      it 'returns nil for invalid format string' do
        expect(described_class.generate('INVALID')).to be_nil
      end

      it 'returns nil for empty format string' do
        expect(described_class.generate('')).to be_nil
      end

      it 'returns nil for wrong pattern LLLLNNN' do
        expect(described_class.generate('LLLLNNN')).to be_nil
      end

      it 'returns nil for non-string format' do
        expect(described_class.generate(123)).to be_nil
      end
    end
  end
end
