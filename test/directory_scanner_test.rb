require File.expand_path("test_helper", File.dirname(__FILE__))
require 'jruby/synchronized'

class FailingTestWorker
  def initialize(file_name, options)
    @file_name = file_name
  end

  def process
    raise @file_name
  end
end

describe "the directory scanner" do
  before do
    prepare_fixture_files
    @file_worker = FileWorker::DirectoryScanner.new(
      :in_directory => @fixture_root + 'in',
      :out_directory => @fixture_root + 'done',
      :max_queue_size => 10
    )

    @errors = []
    @errors.extend JRuby::Synchronized

    @file_worker.on_error do |file_name, exception|
      @errors << file_name
    end
  end

  it "should enqueue the files in the in directory" do
    @file_worker.queue.expects(:push).times(5)
    @file_worker.scan
    @file_worker.wait_for_empty
  end

  it "should move the files to the out directory" do
    @file_worker.scan
    @file_worker.wait_for_empty

    @file_worker.in_path.children.must_be_empty
    @file_worker.done_path.children.size.must_equal(5)
  end

  it "should not enqueue the this same files twice" do
    @file_worker.queue.expects(:push).times(5)
    @file_worker.scan
    @file_worker.wait_for_empty
    @file_worker.scan
    @file_worker.wait_for_empty
  end

  describe "when the worker queue is empty" do
    before do
      @file_worker.stubs(:queue_size).returns(0)
    end

    it "should only enqueue 10 items" do
      prepare_fixture_files(20)
      @file_worker.queue.expects(:push).times(10)
      @file_worker.scan
      @file_worker.wait_for_empty
    end
  end

  describe "when the worker queue has some items in it" do
    before do
      @file_worker.stubs(:queue_size).returns(3)
    end

    it "should not try to over fill the queue" do
      prepare_fixture_files(20)
      @file_worker.queue.expects(:push).times(7)
      @file_worker.scan
      @file_worker.wait_for_empty
    end
  end

  describe "when the worker queue is full" do
    before do
      @file_worker.stubs(:queue_size).returns(10)
    end

    it "should not enqueue anything" do
      prepare_fixture_files(20)
      @file_worker.queue.expects(:push).never
      @file_worker.scan
      @file_worker.wait_for_empty
    end
  end

  describe "when a file is already enqueued" do
    before do
      file_name = Dir.glob(@file_worker.in_path + '*').first
      @file_worker.state[file_name] = {:time => Time.now, :status => :working}
    end

    it "should not enqueue the file again" do
      @file_worker.queue.expects(:push).times(4)
      @file_worker.scan
      @file_worker.wait_for_empty
    end
  end

  describe "when jobs fail" do
    before do
      @file_worker.worker_class = FailingTestWorker
      @file_worker.scan
      @file_worker.wait_for_empty
    end

    it "should call the error handler" do
      @errors.size.must_equal(5)
    end

    it "should not move the files" do
      @file_worker.done_path.children.must_be_empty
      @file_worker.in_path.children.size.must_equal(5)
    end

    it "should remove the files from state" do
      @file_worker.state.must_be_empty
    end
  end

end
