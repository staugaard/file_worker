require 'girl_friday'
require 'fileutils'
require 'jruby/synchronized'

module FileWorker
  class DirectoryScanner
    attr_accessor :worker_class
    attr_reader :in_path, :done_path, :state

    def initialize(options)
      @options   = options
      @in_path   = @options[:root] + 'in'
      @done_path = @options[:root] + 'done'
      @sleep     = @options[:sleep] || 1

      @max_queue_size = @options[:max_queue_size] || 1000

      @worker_class = Worker

      @state = {}
      @state.extend JRuby::Synchronized
      @queue_name = "file_worker"
    end

    def queue
      @queue ||= GirlFriday::WorkQueue.new(@queue_name, :size => 3) do |file_name|
        @state[file_name] = {:time => Time.now, :status => :working}

        @worker_class.new(file_name, @options).process

        FileUtils.mv(file_name, @done_path)

        @state.delete(file_name)
      end
    end

    def queue_size
      queue.status[@queue_name][:backlog]
    end

    def enqueue(file_name)
      @state[file_name] = {:time => Time.now, :status => :enqueued}

      queue.push(file_name)
    end

    def wait_for_empty
      queue.wait_for_empty

      sleep 0.5

      while queue.status[@queue_name][:busy] != 0
        sleep 0.5
      end
    end

    def scan
      file_names = Dir.glob(@in_path + '*') - @state.keys

      max_items = @max_queue_size - queue_size

      file_names[0,max_items].each do |file_name|
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