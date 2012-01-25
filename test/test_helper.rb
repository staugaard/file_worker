$testing = true

require "rubygems"
require "bundler"
Bundler.require

require "minitest/autorun"
require "mocha"
require "pathname"
require "fileutils"
require "fakefs/safe"

MiniTest::Spec.class_eval do
  before do
    FakeFS.activate!
    @fixture_root = Pathname.new(File.dirname(__FILE__)) + "../tmp/fixtures"
    FileUtils.mkdir_p(@fixture_root + "in")
    FileUtils.mkdir_p(@fixture_root + "done")
    clean_fixture_dirs
  end

  after do
    FakeFS.deactivate!
  end

  def clean_fixture_dirs
    FileUtils.rm_rf(Dir.glob(@fixture_root + "in/*"))
    FileUtils.rm_rf(Dir.glob(@fixture_root + "done/*"))
  end

  def prepare_fixture_files(in_files = 5, done_files = 0)
    create_fixture_files(@fixture_root + "in", in_files)
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
