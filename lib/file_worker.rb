require "file_worker/version"

module FileWorker
  autoload :DirectoryScanner, 'file_worker/directory_scanner'
  autoload :DefaultWorker,    'file_worker/default_worker'
  autoload :S3UploadWorker,   'file_worker/s3_upload_worker'
end
