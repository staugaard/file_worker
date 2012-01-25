require File.expand_path("test_helper", File.dirname(__FILE__))

class TestWorker
  def initialize(file_name)
    @file_name = file_name
  end

  def process
    puts 'processing'
  end
end

describe "the directory scanner" do
  before do
    prepare_fixture_files
    @file_worker = FileWorker::DirectoryScanner.new(
      :root => @fixture_root
    )
    @file_worker.worker_class = TestWorker
  end

  it "should enqueue the files in the in directory" do
    @file_worker.expects(:enqueue).times(5)
    @file_worker.scan
    @file_worker.wait_for_empty
  end

  it "should not enqueue the this same files twice" do
    @file_worker.expects(:enqueue).times(5)
    @file_worker.scan
    @file_worker.wait_for_empty
    @file_worker.scan
    @file_worker.wait_for_empty
  end
end
