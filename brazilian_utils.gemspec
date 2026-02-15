# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "br-utils"
  spec.version       = "0.1.0"
  spec.authors       = ["Alex Rocha", "Leonel Sanches da Silva"]
  spec.email         = ["alex.rochas@yahoo.com.br", "leonel@designliquido.com.br"]

  spec.summary       = "Utils library for specific Brazilian business."
  spec.description   = "Brazilian Utils é uma biblioteca com foco na resolução de problemas que enfrentamos diariamente no desenvolvimento de aplicações para negócios no Brasil."
  spec.homepage      = "https://github.com/brazilian-utils/ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) || f.match(%r{\.gemspec$}) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.4"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12"
end
