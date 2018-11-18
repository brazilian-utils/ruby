module BrazilianUtils
  module Helper
    def self.first_digit_check(cpf)
      ((cpf.chars
            .take(9)
            .zip((2..10).to_a.reverse)
            .map do |c, m|
        c.to_i * m
      end.reduce(:+) * 10 % 11) == cpf[9].to_i)
    end

    def self.second_digit_check(cpf)
      ((cpf.chars
            .take(10)
            .zip((2..11).to_a.reverse)
            .map do |c, m|
        c.to_i * m
      end.reduce(:+) * 10 % 11) == cpf[10].to_i)
    end
  end

  module CPFUtils
    include Helper

    BLACKLIST = %w[
      11111111111
      22222222222
      33333333333
      44444444444
      55555555555
      66666666666
      77777777777
      88888888888
      99999999999
    ].freeze

    def self.valid?(cpf)
      return false unless cpf
      return false if cpf.chars.empty?
      return false if BLACKLIST.include? cpf

      Helper.first_digit_check(cpf) && Helper.second_digit_check(cpf)
    end


  end
end
