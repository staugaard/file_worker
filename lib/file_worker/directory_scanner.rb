require 'girl_friday'
require 'fileutils'
require 'jruby/synchronized'
require 'pathname'

module FileWorker
  class DirectoryScanner
    attr_accessor :worker_class
    attr_reader :in_path, :done_path, :state

    def initialize(options)
      @options   = options
      @in_path   = Pathname.new(@options[:in_directory])
      @done_path = Pathname.new(@options[:out_directory])
      @glob_path = @in_path + '**/*'
      @sleep     = @options[:sleep] || 1

      @max_queue_size = @options[:max_queue_size] || 1000

      @worker_class = DefaultWorker

      @state = {}
      @state.extend JRuby::Synchronized
      @queue_name = "file_worker"

      @error_handlers = []
    end

    # This method is called by the worker threads, so remember to keep it thread safe
    def process(file_name)
      @state[file_name] = {:time => Time.now, :status => :working}

      begin
        @worker_class.new(file_name, @options).process

        done_file_name = file_name.sub(@in_path, @done_path)
        FileUtils.mkdir_p(File.dirname(done_file_name))
        FileUtils.mv(file_name, done_file_name)
      rescue Exception => e
        handle_error(file_name, e)
      end

      @state.delete(file_name)
    end

    def queue
      @queue ||= GirlFriday::WorkQueue.new(@queue_name, :size => 3) do |file_name|
        process(file_name)
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
      file_names = Dir.glob(@glob_path) - @state.keys
      file_names.reject! { |file_name| File.directory?(file_name) }

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

    def on_error(&block)
      @error_handlers << block
    end

    def handle_error(file_name, exception)
      @error_handlers.each do |error_handler|
        error_handler.call(file_name, exception)
      end
    end
  end
end