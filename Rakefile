require "bundler/gem_tasks"

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'double_doc'
  DoubleDoc::Task.new(:doc,
    :title => 'File Worker',
    :sources => 'doc/README.md',
    :md_destination => '.',
    :html_destination => 'site'
  )
rescue LoadError => e
end

task :default => :test
