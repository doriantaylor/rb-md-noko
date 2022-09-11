# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'md/noko/version'

Gem::Specification.new do |spec|
  spec.name          = 'md-noko'
  spec.version       = MD::Noko::VERSION
  spec.authors       = ['Dorian Taylor']
  spec.email         = ['code@doriantaylor.com']
  spec.license       = 'Apache-2.0'
  spec.summary       = %q{In goes Markdown, out pops Nokogiri.}
  spec.description   = <<-DESC
This is a simple module that encapsulates a set of desirable
manipulations to the (X)HTML output of Redcarpet, producing a
Nokogiri::XML::Document which is amenable to further manipulation.
  DESC
  spec.homepage      = 'https://github.com/doriantaylor/rb-md-noko'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0'

  spec.add_development_dependency "bundler", ">= 2.1"
  spec.add_development_dependency "rake", ">= 13.0"
  spec.add_development_dependency "rspec", ">= 3.9"

  spec.add_runtime_dependency 'redcarpet', '>= 3.5'
  spec.add_runtime_dependency 'xml-mixup', '>= 0.1.14'
end
