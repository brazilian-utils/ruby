require 'spec_helper'

describe BrazilianUtils::CPFUtils do
  it 'is a valid cpf valid' do
    expect(BrazilianUtils::CPFUtils.valid?('41840660546')).to be true
  end

  it 'is passed an nil cpf' do
    expect(BrazilianUtils::CPFUtils.valid?(nil)).to be false
  end

  it 'is passed an empty cpf' do
    expect(BrazilianUtils::CPFUtils.valid?('')).to be false
  end

  %w[
    11111111111
    22222222222
    33333333333
    44444444444
    55555555555
    66666666666
    77777777777
    88888888888
    99999999999
  ].each do |invalid_cpf|
    it "is passed an invalid cpf #{invalid_cpf}" do
      expect(BrazilianUtils::CPFUtils.valid?(invalid_cpf)).to be false
    end
  end
end
