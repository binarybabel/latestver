# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'latestver/version'

Gem::Specification.new do |spec|
  spec.name          = 'latestver'
  spec.version       = Latestver::VERSION
  spec.authors       = ['BinaryBabel OSS']
  spec.email         = ['oss@binarybabel.org']

  spec.summary       = 'Latestver command-line interface. Hosted or privately deployed. Project sync coming soon.'
  spec.homepage      = 'https://lv.binarybabel.org'
  spec.license       = 'GNU GPL 3'

  spec.files         = Dir.glob('{bin,exe,lib}/**/*') + %w(
                          LICENSE.txt README.md
                       )
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.files += ['version.lock']
  spec.add_dependency 'versioneer'

  spec.add_runtime_dependency 'faraday'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  if RUBY_VERSION > '2.3'
    spec.add_development_dependency 'pry', '~> 0.10.0'
    spec.add_development_dependency 'pry-byebug', '> 3'
  end
end
