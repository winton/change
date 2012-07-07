# -*- encoding: utf-8 -*-
root = File.expand_path('../', __FILE__)
lib = "#{root}/lib"

$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = "change"
  s.version     = '0.1.2'
  s.platform    = Gem::Platform::RUBY
  s.authors     = [ 'Winton Welsh' ]
  s.email       = [ 'mail@wintoni.us' ]
  s.homepage    = "http://github.com/winton/change"
  s.summary     = %q{What files changed since last time?}
  s.description = %q{What files changed since last time? With dependency management and super fast hashing (Murmur3).}

  s.executables = `cd #{root} && git ls-files bin/*`.split("\n").collect { |f| File.basename(f) }
  s.extensions = [ 'ext/change/extconf.rb' ]
  s.files = `cd #{root} && git ls-files`.split("\n")
  s.require_paths = %w(lib)
  s.test_files = `cd #{root} && git ls-files -- {features,test,spec}/*`.split("\n")

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~> 1.0"
end