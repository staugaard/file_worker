require File.expand_path("test_helper", File.dirname(__FILE__))

describe "a worker" do
  it "should fail when not provided auth options" do
    assert_raises(IndexError) { FileWorker::Worker.new("/path/to/file.name", {}) }
  end

  describe "instantiated correctly" do
    before do
      @options   = {
        :aws_access_key_id     => "some key",
        :aws_secret_access_key => "other key"
      }

      @file_name = "/path/to/file.name"
      @worker    = FileWorker::Worker.new(@file_name, @options.merge(:aws_s3_bucket => "files"))
    end

    describe "process" do
      it "should attempt to transfer to the location" do
        files  = stub()
        bucket = stub(:files => files)
        files.expects(:create).with({

        })

        @worker.expects(:bucket).returns(bucket)
        @worker.process
      end
    end
  end
end
