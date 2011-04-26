# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "kenexa/version"

Gem::Specification.new do |s|
  s.name        = "kenexa"
  s.version     = Kenexa::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Michael Guterl"]
  s.email       = ["michael@recruitmilitary.com"]
  s.homepage    = ""
  s.summary     = %q{A simple ruby wrapper for the Kenexa API}
  s.description = %q{A simple ruby wrapper for the Kenexa API}

  s.rubyforge_project = "kenexa"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'nokogiri'

  s.add_development_dependency 'minitest'
  s.add_development_dependency 'webmock'
end
