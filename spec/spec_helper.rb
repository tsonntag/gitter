#require 'rubygems'
#require 'bundler'
#Bundler.setup :default, :development

$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../lib', __FILE__)

require 'rspec'
require 'tracks_grid'

require 'support/database'

Dir[File.dirname(__FILE__) + '/support/*.rb'].each{|f| require f}

def check_include(*args)
  params = args.extract_options!
  scope = PersonGrid.new(:params => params).scope
  puts "SSSSSSSSSSS scope=#{scope.to_sql}"
  all = Set.new scope.all
  puts "            all=#{all.inspect}"
  expected = Set.new [args].flatten
  puts "            expected=#{expected.inspect}"
  specify { all.should == expected }
end

class Array
  def detect_name( name)
    detect{|d| d.name == name }
  end
end

