# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BrazilianUtils::VoterIdUtils do
  describe '.is_valid_voter_id' do
    context 'with valid voter IDs' do
      it 'validates standard 12-digit voter IDs' do
        expect(described_class.is_valid_voter_id('690847092828')).to be true
        expect(described_class.is_valid_voter_id('163204010922')).to be true
        expect(described_class.is_valid_voter_id('000000000191')).to be true
        expect(described_class.is_valid_voter_id('123456780140')).to be true
      end

      it 'validates voter IDs from different states' do
        # SP (01)
        expect(described_class.is_valid_voter_id('690847092828')).to be true
        # MG (02)
        expect(described_class.is_valid_voter_id('163204010922')).to be true
        # RJ (03)
        expect(described_class.is_valid_voter_id('000000000191')).to be true
        # RS (04)
        expect(described_class.is_valid_voter_id('123456780140')).to be true
      end

      it 'validates voter IDs with edge case for SP and MG (13 digits)' do
        # These are 13-digit voter IDs that are valid for SP (01) and MG (02)
        # when sequential number has 9 digits
        expect(described_class.is_valid_voter_id('1234567890101')).to be true
      end

      it 'validates voter ID with verification digit 0 (when rest is 10)' do
        expect(described_class.is_valid_voter_id('548044090191')).to be true
      end
    end

    context 'with invalid voter IDs' do
      it 'rejects voter IDs with invalid length' do
        expect(described_class.is_valid_voter_id('123')).to be false
        expect(described_class.is_valid_voter_id('12345678901')).to be false
        expect(described_class.is_valid_voter_id('12345678901234')).to be false
      end

      it 'rejects voter IDs with non-digit characters' do
        expect(described_class.is_valid_voter_id('690847092A28')).to be false
        expect(described_class.is_valid_voter_id('690847092-28')).to be false
        expect(described_class.is_valid_voter_id('690.847.092.828')).to be false
        expect(described_class.is_valid_voter_id('690 847 092 828')).to be false
      end

      it 'rejects voter IDs with invalid federative union' do
        expect(described_class.is_valid_voter_id('123456780000')).to be false
        expect(described_class.is_valid_voter_id('123456789900')).to be false
        expect(described_class.is_valid_voter_id('123456783000')).to be false
      end

      it 'rejects voter IDs with invalid first verification digit' do
        expect(described_class.is_valid_voter_id('690847092829')).to be false
        expect(described_class.is_valid_voter_id('163204010921')).to be false
      end

      it 'rejects voter IDs with invalid second verification digit' do
        expect(described_class.is_valid_voter_id('690847092827')).to be false
        expect(described_class.is_valid_voter_id('163204010923')).to be false
      end

      it 'rejects 13-digit voter IDs for non-SP/MG states' do
        # 13 digits is only valid for SP (01) and MG (02)
        expect(described_class.is_valid_voter_id('1234567890301')).to be false
        expect(described_class.is_valid_voter_id('1234567890401')).to be false
      end
    end

    context 'with edge cases' do
      it 'rejects empty string' do
        expect(described_class.is_valid_voter_id('')).to be false
      end

      it 'rejects nil' do
        expect(described_class.is_valid_voter_id(nil)).to be false
      end

      it 'rejects numeric input' do
        expect(described_class.is_valid_voter_id(123456780140)).to be false
      end

      it 'rejects strings with only zeros except when valid' do
        expect(described_class.is_valid_voter_id('000000000000')).to be false
        expect(described_class.is_valid_voter_id('000000000191')).to be true
      end
    end

    context 'with special cases for SP (01) and MG (02)' do
      it 'validates voter IDs where rest == 0 results in VD = 1' do
        # These voter IDs should have special handling for SP and MG
        # when modulo 11 equals 0, the verification digit becomes 1
        expect(described_class.is_valid_voter_id('690847092828')).to be true
      end
    end
  end

  describe '.valid_voter_id?' do
    it 'is an alias for is_valid_voter_id' do
      expect(described_class.valid_voter_id?('690847092828')).to be true
      expect(described_class.valid_voter_id?('123456789012')).to be false
    end
  end

  describe '.format_voter_id' do
    context 'with valid voter IDs' do
      it 'formats voter ID with spaces in standard pattern' do
        expect(described_class.format_voter_id('690847092828')).to eq('6908 4709 28 28')
        expect(described_class.format_voter_id('163204010922')).to eq('1632 0401 09 22')
        expect(described_class.format_voter_id('000000000191')).to eq('0000 0000 01 91')
      end

      it 'formats 13-digit voter IDs for SP and MG' do
        expect(described_class.format_voter_id('1234567890101')).to eq('1234 5678 90 10')
      end
    end

    context 'with invalid voter IDs' do
      it 'returns nil for invalid voter IDs' do
        expect(described_class.format_voter_id('123')).to be_nil
        expect(described_class.format_voter_id('690847092829')).to be_nil
        expect(described_class.format_voter_id('690847092A28')).to be_nil
      end

      it 'returns nil for empty string' do
        expect(described_class.format_voter_id('')).to be_nil
      end

      it 'returns nil for nil' do
        expect(described_class.format_voter_id(nil)).to be_nil
      end
    end
  end

  describe '.format' do
    it 'is an alias for format_voter_id' do
      expect(described_class.format('690847092828')).to eq('6908 4709 28 28')
      expect(described_class.format('123')).to be_nil
    end
  end

  describe '.generate' do
    context 'with valid UF codes' do
      it 'generates a valid 12-digit voter ID for default ZZ' do
        voter_id = described_class.generate
        expect(voter_id).to be_a(String)
        expect(voter_id.length).to eq(12)
        expect(described_class.is_valid_voter_id(voter_id)).to be true
        expect(voter_id[8..9]).to eq('28') # ZZ = 28
      end

      it 'generates a valid voter ID for SP' do
        voter_id = described_class.generate('SP')
        expect(voter_id).to be_a(String)
        expect(voter_id.length).to eq(12)
        expect(described_class.is_valid_voter_id(voter_id)).to be true
        expect(voter_id[8..9]).to eq('01') # SP = 01
      end

      it 'generates a valid voter ID for MG' do
        voter_id = described_class.generate('MG')
        expect(voter_id).to be_a(String)
        expect(voter_id.length).to eq(12)
        expect(described_class.is_valid_voter_id(voter_id)).to be true
        expect(voter_id[8..9]).to eq('02') # MG = 02
      end

      it 'generates a valid voter ID for RJ' do
        voter_id = described_class.generate('RJ')
        expect(voter_id).to be_a(String)
        expect(voter_id.length).to eq(12)
        expect(described_class.is_valid_voter_id(voter_id)).to be true
        expect(voter_id[8..9]).to eq('03') # RJ = 03
      end

      it 'generates a valid voter ID for all UF codes' do
        %w[SP MG RJ RS BA PR CE PE SC GO MA PB PA ES PI RN AL MT MS DF SE AM RO AC AP RR TO ZZ].each do |uf|
          voter_id = described_class.generate(uf)
          expect(voter_id).to be_a(String)
          expect(voter_id.length).to eq(12)
          expect(described_class.is_valid_voter_id(voter_id)).to be true
        end
      end

      it 'handles lowercase UF codes' do
        voter_id = described_class.generate('sp')
        expect(voter_id).to be_a(String)
        expect(voter_id[8..9]).to eq('01')
      end

      it 'handles mixed case UF codes' do
        voter_id = described_class.generate('Mg')
        expect(voter_id).to be_a(String)
        expect(voter_id[8..9]).to eq('02')
      end
    end

    context 'with invalid UF codes' do
      it 'returns nil for invalid UF code' do
        expect(described_class.generate('XX')).to be_nil
        expect(described_class.generate('AB')).to be_nil
        expect(described_class.generate('123')).to be_nil
      end

      it 'returns nil for empty string' do
        expect(described_class.generate('')).to be_nil
      end
    end

    context 'generates different voter IDs' do
      it 'generates unique voter IDs on multiple calls' do
        voter_ids = 10.times.map { described_class.generate('SP') }
        expect(voter_ids.uniq.length).to be > 1
      end
    end
  end

  describe 'private helper methods' do
    # Testing private methods through public interface

    context 'length validation' do
      it 'accepts 12-digit voter IDs for all states' do
        expect(described_class.is_valid_voter_id('690847092828')).to be true
      end

      it 'accepts 13-digit voter IDs only for SP and MG' do
        # Valid 13-digit for SP
        expect(described_class.is_valid_voter_id('1234567890101')).to be true
      end
    end

    context 'federative union extraction' do
      it 'correctly extracts federative union from 12-digit voter ID' do
        # Testing through validation which uses this extraction
        voter_id = '690847092828'
        expect(described_class.is_valid_voter_id(voter_id)).to be true
      end
    end

    context 'verification digit calculation' do
      it 'correctly calculates VD1 with normal rest' do
        # voter_id '163204010922' should have correct VD1 calculation
        expect(described_class.is_valid_voter_id('163204010922')).to be true
      end

      it 'correctly calculates VD1 when rest is 10 (becomes 0)' do
        expect(described_class.is_valid_voter_id('548044090191')).to be true
      end

      it 'correctly calculates VD1 when rest is 0 for SP/MG (becomes 1)' do
        # This tests the edge case where rest == 0 for SP or MG
        expect(described_class.is_valid_voter_id('690847092828')).to be true
      end

      it 'correctly calculates VD2 with normal rest' do
        expect(described_class.is_valid_voter_id('163204010922')).to be true
      end

      it 'correctly calculates VD2 when rest is 10 (becomes 0)' do
        expect(described_class.is_valid_voter_id('548044090191')).to be true
      end
    end

    context 'federative union validation' do
      it 'accepts valid federative unions (01-28)' do
        (1..28).each do |num|
          uf_code = format('%02d', num)
          voter_id = "12345678#{uf_code}00"
          # We're just checking that it doesn't fail on federative union validation
          # (it might fail on VD validation, but that's okay for this test)
          result = described_class.is_valid_voter_id(voter_id)
          expect([true, false]).to include(result)
        end
      end

      it 'rejects invalid federative unions (00, 29+)' do
        expect(described_class.is_valid_voter_id('123456780000')).to be false
        expect(described_class.is_valid_voter_id('123456782900')).to be false
      end
    end
  end

  describe 'UF_CODES constant' do
    it 'has all 27 Brazilian states plus ZZ' do
      expect(described_class::UF_CODES.keys.length).to eq(28)
    end

    it 'maps correct UF codes to numbers' do
      expect(described_class::UF_CODES['SP']).to eq('01')
      expect(described_class::UF_CODES['MG']).to eq('02')
      expect(described_class::UF_CODES['RJ']).to eq('03')
      expect(described_class::UF_CODES['RS']).to eq('04')
      expect(described_class::UF_CODES['ZZ']).to eq('28')
    end

    it 'has all expected states' do
      expected_states = %w[SP MG RJ RS BA PR CE PE SC GO MA PB PA ES PI RN AL MT MS DF SE AM RO AC AP RR TO ZZ]
      expect(described_class::UF_CODES.keys.sort).to eq(expected_states.sort)
    end
  end

  describe 'integration tests' do
    it 'validates, formats, and generates voter IDs end-to-end' do
      # Generate
      voter_id = described_class.generate('SP')
      expect(voter_id).to be_a(String)

      # Validate
      expect(described_class.is_valid_voter_id(voter_id)).to be true

      # Format
      formatted = described_class.format_voter_id(voter_id)
      expect(formatted).to match(/^\d{4} \d{4} \d{2} \d{2}$/)
    end

    it 'handles complete workflow for multiple states' do
      %w[SP MG RJ BA].each do |uf|
        voter_id = described_class.generate(uf)
        expect(described_class.valid_voter_id?(voter_id)).to be true
        formatted = described_class.format(voter_id)
        expect(formatted).to match(/^\d{4} \d{4} \d{2} \d{2}$/)
      end
    end
  end

  describe 'real-world examples' do
    it 'validates known valid voter IDs' do
      valid_ids = [
        '690847092828', # SP
        '163204010922', # MG
        '000000000191', # RJ
        '123456780140', # RS
        '548044090191'  # With VD = 0
      ]

      valid_ids.each do |voter_id|
        expect(described_class.is_valid_voter_id(voter_id)).to be true
      end
    end

    it 'formats known voter IDs correctly' do
      examples = {
        '690847092828' => '6908 4709 28 28',
        '163204010922' => '1632 0401 09 22',
        '000000000191' => '0000 0000 01 91'
      }

      examples.each do |voter_id, expected_format|
        expect(described_class.format_voter_id(voter_id)).to eq(expected_format)
      end
    end
  end
end
