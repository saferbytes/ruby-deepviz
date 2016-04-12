Gem::Specification.new do |spec|
  spec.name          = 'ruby-deepviz'
  spec.version       = '1.0.2'
  spec.email         = 'info@deepviz.com'
  spec.authors       = ['Saferbytes S.r.l.s.']

  spec.summary       = 'ruby-deepviz is a Ruby wrapper for deepviz.com REST APIs'
  spec.homepage      = 'https://www.deepviz.com'
  spec.license       = 'MIT'

  spec.files         = [
    'lib/deepviz/intel.rb',
    'lib/deepviz/result.rb',
    'lib/deepviz/sandbox.rb',
  ]

  spec.add_development_dependency 'bundler', '~> 1.12.a'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'unirest', '~> 1.1.2'
end
