require File.expand_path("test_helper", File.dirname(__FILE__))

describe "an s3 upload worker" do
  before do
    @file_name = "/path/to/file.name"
  end

  it "should fail when not provided auth options" do
    assert_raises(IndexError) { FileWorker::S3UploadWorker.new(@file_name, {}) }
  end

  describe "instantiated correctly" do
    before do
      ENV["S3_BUCKET"]             = "files"
      ENV["AWS_ACCESS_KEY_ID"]     = "some key"
      ENV["AWS_SECRET_ACCESS_KEY"] = "other key"

      @worker = FileWorker::S3UploadWorker.new(@file_name, {})
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
