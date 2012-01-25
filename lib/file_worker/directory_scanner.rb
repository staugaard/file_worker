require 'girl_friday'
require 'fileutils'
require 'jruby/synchronized'

module FileWorker
  class DirectoryScanner
    attr_accessor :worker_class

    def initialize(options)
      @options   = options
      @in_path   = @options[:root] + 'in'
      @done_path = @options[:root] + 'done'
      @sleep     = @options[:sleep] || 1

      @worker_class = Worker

      @state = {}
      @state.extend JRuby::Synchronized
    end

    def queue
      @queue ||= GirlFriday::WorkQueue.new(:file_worker, :size => 3) do |file_name|
        @state[file_name] = {:time => Time.now, :status => :working}

        @worker_class.new(file_name, @options).process

        FileUtils.mv(file_name, @done_path)

        @state.delete(file_name)
      end
    end

    def enqueue(file_name)
      @state[file_name] = {:time => Time.now, :status => :enqueued}

      queue.push(file_name)
    end

    def wait_for_empty
      queue.wait_for_empty
    end

    def scan
      file_names = Dir.glob(@in_path + '*') - @state.keys
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