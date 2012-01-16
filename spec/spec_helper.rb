#require 'rubygems'
#require 'bundler'
#Bundler.setup :default, :development

$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../lib', __FILE__)

require 'rspec'
require 'tracks_grid'

Dir[File.dirname(__FILE__) + '/support/*.rb'].each{|f| require f}

def check_include(*args)
  params = args.extract_options!
  all = Set.new PersonGrid.new(:params => params).scope.all
  expected = Set.new [args].flatten
  specify { all.should == expected }
end
