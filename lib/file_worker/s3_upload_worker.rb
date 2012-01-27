require "right_aws"

module FileWorker
  class S3UploadWorker
    def initialize(file_name, options)
      @file_name   = file_name
      @bucket_name = ENV.fetch("S3_BUCKET")
    end

    def process
      s3.put(@bucket_name, File.basename(@file_name), File.open(@file_name))
    end

    private

    def s3
      @s3 ||= RightAws::S3Interface.new
    end
  end
end
