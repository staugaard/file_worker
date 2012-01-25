require "file_worker/version"

module FileWorker
  autoload :DirectoryScanner, 'file_worker/directory_scanner'
  autoload :Worker,           'file_worker/worker'
end
