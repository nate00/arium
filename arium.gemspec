require File.expand_path('../lib/arium/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'arium'
  s.summary     = s.description = 'Make a fun map'
  s.authors     = ['Nate Sullivan']
  s.email       = 'nathanielsullivan00@gmail.com'
  s.homepage    = 'http://github.com/nate00/arium'
  s.license     = 'MIT'

  s.version     = Arium::VERSION
  s.files       = Dir['lib/**/*.rb', '*.md']

  s.add_runtime_dependency      'whenever', '~> 0.9.4'
  s.add_runtime_dependency      'colorize', '~> 0.7.5'
  s.add_runtime_dependency      'chunky_png', '~> 1.3.3'
  s.add_runtime_dependency      'activesupport', '~> 4.2.0'

  s.add_development_dependency  'pry', '~> 0.10.1'
end
