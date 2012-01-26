# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "file_worker/version"

Gem::Specification.new do |s|
  s.name        = "file_worker"
  s.version     = FileWorker::VERSION
  s.authors     = ["Mick Staugaard"]
  s.email       = ["mick@staugaard.com"]
  s.homepage    = ""
  s.summary     = "A multi-threaded worker that takes files as input"
  s.description = "If you have files that you some how need to process, file_worker is your friend."

  s.files         = Dir['lib/**/*'] + %w(README.md)
  s.test_files    = Dir['test/**/*']
  s.executables   = ['file_worker']
  s.require_paths = ["lib"]

  s.add_development_dependency "rake"
  s.add_development_dependency "minitest"
  s.add_development_dependency "mocha"

  s.add_runtime_dependency "jruby-openssl"
  s.add_runtime_dependency "girl_friday"
  s.add_runtime_dependency "fog"
end
