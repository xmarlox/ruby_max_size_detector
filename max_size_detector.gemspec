Gem::Specification.new do |s|
  s.name        = "max_size_detector"
  s.version     = "0.1.0"
  s.executables << "max_size_detector"
  s.summary     = "Ruby Max Size Detector"
  s.description = "This gem allows you to analyze an input file (contains several terminal commands and output related to files and directories) and finally detect all directories candidate for deletion based on the maximum size."
  s.authors     = ["MarLo MoraLes"]
  s.email       = "moralesmarlo@hotmail.com"
  s.files       = ["lib/max_size_detector.rb", "lib/max_size_detector/base.rb"]
  s.homepage    = "https://rubygems.org/gems/ruby_max_size_detector"
  s.license     = "MIT"
end
