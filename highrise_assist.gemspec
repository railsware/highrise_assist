# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "highrise_assist/version"

Gem::Specification.new do |s|
  s.name        = "highrise_assist"
  s.version     = HighriseAssist::VERSION
  s.authors     = ["Andriy Yanko"]
  s.email       = ["andriy.yanko@gmail.com"]
  s.homepage    = "https://github.com/railsware/highrise_assist"
  s.summary     = %q{Assist for 37signals' highrise}
  s.description = %q{Assist for 37signals' highrise}

  s.rubyforge_project = "highrise_assist"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "highrise", "~>3.0.0"
  s.add_runtime_dependency "net-http-persistent", "~>2.3"
end
