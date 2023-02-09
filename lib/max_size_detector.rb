class MaxSizeDetector
  FILES_MAX_SIZE = 100_000

  def self.run(**opts)
    file = opts[:file] || opts[:filename]
    max_size = opts[:max_size]

    print "Opening file #{file} ..."
    base = Base.new(**opts)
    return puts "" if base.input_file.nil?

    random_done!

    print "Extracting file structure ..."
    base.extract!
    random_done!

    print "Finding directories up to #{max_size} ..."
    base.process!
    random_done!

    puts "Output:"
    puts base.show_output
  end

  private

  def self.random_done!
    sleep(rand(2..7))
    print " DONE!\n"
  end
end

require "max_size_detector/base"
