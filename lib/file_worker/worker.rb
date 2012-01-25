require "fog"

module FileWorker
  class Worker
    def initialize(file_name, options)
      @file_name  = file_name
      @bucket     = options.fetch(:aws_s3_bucket)
      @aws_key_id = options.fetch(:aws_access_key_id)
      @aws_secret = options.fetch(:aws_secret_access_key)
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
      connection.directories.get(@bucket)
    end
  end
end
