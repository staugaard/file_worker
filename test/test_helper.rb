$testing = true

require "rubygems"
require "bundler"
Bundler.require

require "minitest/autorun"
require "mocha"
require "pathname"
require "fileutils"

MiniTest::Spec.class_eval do
  before do
    @fixture_root = Pathname.new(File.dirname(__FILE__)) + "../tmp/fixtures"
    clean_fixture_dirs
  end

  def clean_fixture_dirs
    FileUtils.rm_rf(Dir.glob(@fixture_root + "in/*"))
    FileUtils.rm_rf(Dir.glob(@fixture_root + "processing/*"))
    FileUtils.rm_rf(Dir.glob(@fixture_root + "done/*"))
  end

  def prepare_fixture_files(in_files = 5, processing_files = 0, done_files = 0)
    create_fixture_files(@fixture_root + "in", in_files)
    create_fixture_files(@fixture_root + "processing", processing_files)
    create_fixture_files(@fixture_root + "done", done_files)
  end

  def create_fixture_files(path, number)
    number.times do |n|
      File.open(path + n.to_s, "w") do |file|
        file.write(n.to_s)
      end
    end
  end
end
