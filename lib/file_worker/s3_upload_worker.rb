require "fog"

module FileWorker
  class S3UploadWorker
    def initialize(file_name, options)
      @file_name   = file_name
      @bucket_name = ENV.fetch("S3_BUCKET")
      @aws_key_id  = ENV.fetch("AWS_ACCESS_KEY_ID")
      @aws_secret  = ENV.fetch("AWS_SECRET_ACCESS_KEY")
    end

    def process
      bucket.files.create(
        :key    => File.basename(@file_name),
        :body   => File.open(@file_name),
        :public => false
      )
    end

    private

    def connection
      @connection ||= Fog::Storage.new(
        :provider              => "AWS",
        :aws_access_key_id     => @aws_key_id,
        :aws_secret_access_key => @aws_secret
      )
    end

    def bucket
      connection.directories.get(@bucket_name)
    end
  end
end
