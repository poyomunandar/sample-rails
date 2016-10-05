# -*- encoding: utf-8 -*-
   $:.push File.expand_path("../lib", __FILE__)
   require "agent/version"
 
   Gem::Specification.new do |s|
    s.name        = "agent"
    s.version     = Agent::VERSION
    s.platform    = Gem::Platform::RUBY
    s.authors     = ["Poyo Munandar Panggabean"]
    s.email       = ["p.munandar.p@gmail.com"]
    s.summary     = %q{Agent Application}
    s.description = %q{Agent for collecting CPU usage, runing processes, and disk usage and provide it through a specific TCP port}
 
    s.rubyforge_project = "crossover_trial_agent"
 
    s.files         = `git ls-files`.split("\n")
    s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
    s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
    s.require_paths = ["lib"]
    s.add_dependency "sinatra"
    s.add_dependency "httparty"
   end