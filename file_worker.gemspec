# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "file_worker/version"

Gem::Specification.new do |s|
  s.name        = "file_worker"
  s.version     = FileWorker::VERSION
  s.authors     = ["Mick Staugaard"]
  s.email       = ["mick@staugaard.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.files         = Dir['lib/**/*'] + %w(README.md)
  s.test_files    = Dir['test/**/*']
  s.executables   = Dir['bin/**/*']
  s.require_paths = ["lib"]

  s.add_development_dependency "minitest"
  s.add_development_dependency "mocha"

  s.add_runtime_dependency "jruby-openssl"
  s.add_runtime_dependency "girl_friday"
  s.add_runtime_dependency "fog"
end
