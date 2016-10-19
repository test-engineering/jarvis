# coding: utf-8

lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name        = 'jarvis'
  gem.version     = '0.0.1'
  gem.date        = '2016-09-05'
  gem.summary     = 'Jarvis'
  gem.description = 'Blaze Meter create plan helper!'
  gem.authors     = ['Cassio Kenji',
                     'Evandro Matioli',
                     'Karoline Leite',
                     'Luis Felipe P. Benassi',
                     'Luiz Perreira']

  gem.files       = `git ls-files`.split("\n")
  gem.executables   = ['jarvis']
  gem.require_paths = ['lib']
  gem.license       = 'MIT'

  gem.add_dependency 'thor', '0.19.1'
  gem.add_dependency 'inquirer', '0.2.1'
  gem.add_dependency 'colorize', '0.7.4'
  gem.add_dependency 'retriable'
  gem.add_dependency 'httparty'
  gem.add_dependency 'artii'
  gem.add_dependency 'httmultiparty'
end
