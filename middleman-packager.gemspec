# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "middleman-deploy/pkg-info"

Gem::Specification.new do |s|
  s.name        = Middleman::Packager::PACKAGE
  s.version     = Middleman::Packager::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Spencer Rhodes"]
  s.email       = ["spencer at spencer dash rhodes dot com"]
  s.homepage    = "http://github.com/oobleck/middleman-packager"
  s.summary     = "Adds package option to mm-build" #Middleman::Packager::TAGLINE
  s.description = s.summary # Middleman::Packager::TAGLINE
  s.license     = "MIT"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # The version of middleman-core your extension depends on
  s.add_runtime_dependency("middleman-core", [">= 3.0.0"])

  # Additional dependencies
  # s.add_runtime_dependency("ptools")
  # s.add_runtime_dependency("net-sftp")
end