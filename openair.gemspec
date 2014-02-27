# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'openair/version'

Gem::Specification.new do |s|
  s.name = "openair"
  s.version = OpenAir::VERSION

  s.authors = ["Micah Young"]
  s.email = ["micah@young.io"]
  s.description = "OpenAir library"
  s.licenses = "MIT"

  s.files = Dir.glob("{lib,spec}/**/*") + %w(README.md MIT-LICENSE)

  s.homepage = "http://github.com/micahyoung/openair"
  s.require_paths = ["lib"]
  s.rubygems_version = "0.0.2"
  s.summary = "An OpenAir client for Ruby"

  s.add_runtime_dependency("typhoeus", ["~> 0.6.7"])
  s.add_runtime_dependency("nokogiri", ["~> 1.6.1"])
  s.add_runtime_dependency("nori", ["~> 2.1.0"])

  s.add_development_dependency("rspec", ["~> 2.8.0"])
end
