module FileWorker
  class DefaultWorker
    def initialize(file_name, options)
      @file_name   = file_name
    end

    def process
      puts @file_name
    end
  end
end
