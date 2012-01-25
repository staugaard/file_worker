module FileWorker
  class Worker
    def initialize(file_name)
      @file_name = file_name
    end

    def process
      puts "processing #{@file_name}"
    end
  end
end
