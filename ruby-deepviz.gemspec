# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'deepviz/version'

Gem::Specification.new do |spec|
  spec.name          = 'ruby-deepviz'
  spec.version       = Deepviz::VERSION
  spec.email         = ['info@deepviz.com']
  spec.authors       = ['Saferbytes S.r.l.s.']

  spec.summary       = 'ruby-deepviz is a Ruby wrapper for deepviz.com REST APIs'
  spec.homepage      = 'https://www.deepviz.com'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split('\x0').reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.12.a'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'unirest', '~> 1.1.2'
end
