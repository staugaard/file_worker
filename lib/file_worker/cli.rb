require 'optparse'

module FileWorker
  class Cli
    def self.build_scanner
      options = {
        :workers => 5
      }

      OptionParser.new do |opts|
        opts.banner = "Usage: #{$0} [options]"

        opts.on("-w", "--workers [NUMBER]", "The number of worker threads") do |workers|
          options[:workers] = workers.to_i
        end

        opts.on("-o", "--out [DIRECTORY]", "The directory to put the files when they have been processed") do |out|
          options[:out_directory] = out
        end

        opts.on("-s", "--sleep [NUMBER]", Float, "The number of seconds to sleep between scanning the in-directory") do |sleep_time|
          options[:sleep] = sleep_time
        end

        opts.on("-q", "--queuesize [NUMBER]", "The maximum queue size to keep in memory") do |max_queue_size|
          options[:max_queue_size] = max_queue_size.to_i
        end

        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end
      end.parse!

      if root = ARGV[0]
        options[:in_directory] = File.expand_path(root, Dir.pwd)
      else
        options[:in_directory] = Dir.pwd
      end

      options[:out_directory] ||= File.expand_path('../done', options[:in_directory])

      DirectoryScanner.new(options)
    end
  end
end
