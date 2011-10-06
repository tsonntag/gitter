# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "tracks_grid/version"

Gem::Specification.new do |s|
  s.name        = "tracks_grid"
  s.version     = TracksGrid::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Thomas Sommtag"]
  s.email       = ["git@sonntagsbox.de"]
  s.homepage    = "http://github.com/tracksun/tracks_grid"
  s.summary     = %q{Ruby gem to define searches, facets and data grids for Rails applications}
  s.description     = <<-EOS
    To be used within Rails applications.
    Helps you to define searches with filters and facets 
    and data tables with sortable columns and filters.
  EOS

  s.rubyforge_project = "tracks_grid"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
