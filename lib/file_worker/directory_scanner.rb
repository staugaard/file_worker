require 'girl_friday'

module FileWorker
  class DirectoryScanner
    attr_accessor :in_path, :processing, :done_path, :worker_class

    def initialize(options)
      @options = options
      @in_path         = @options[:root] + 'in'
      @processing_path = @options[:root] + 'processing'
      @done_path       = @options[:root] + 'done'
      @sleep           = 1

      @worker_class = Worker
    end

    def queue
      @queue ||= GirlFriday::WorkQueue.new(:file_worker, :size => 3) do |file_name|
        @worker_class.new(file_name).process
      end
    end

    def enqueue(file_name)
      puts "enqueueing #{file_name}"
      queue.push(file_name)
    end

    def wait_for_empty
      queue.wait_for_empty
    end

    def scan
      file_names = Dir.glob(@in_path + '*')
      file_names.each do |file_name|
        enqueue(file_name)
      end
    end

    def start
      @run = true
      while @run
        scan
        sleep(@sleep)
      end
    end

    def stop
      @run = false
    end
  end
end