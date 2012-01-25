require File.expand_path("test_helper", File.dirname(__FILE__))

describe "a worker" do
  before do
    @file_name = "/path/to/file.name"
  end

  it "should fail when not provided auth options" do
    assert_raises(IndexError) { FileWorker::Worker.new(@file_name, {}) }
  end

  describe "instantiated correctly" do
    before do
      @options = {
        :aws_access_key_id     => "some key",
        :aws_secret_access_key => "other key"
      }

      @worker = FileWorker::Worker.new(@file_name, @options.merge(:aws_s3_bucket => "files"))
    end

    describe "process" do
      it "should attempt to transfer to the location" do
        file   = stub()
        File.expects(:open).with(@file_name).returns(file)

        files  = stub()
        bucket = stub(:files => files)
        files.expects(:create).with(:key => File.basename(@file_name), :body => file, :public => false)

        @worker.expects(:bucket).returns(bucket)
        @worker.process
      end
    end
  end
end
