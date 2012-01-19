#require 'rubygems'
#require 'bundler'
#Bundler.setup :default, :development

require 'rspec'
require 'i18n'
require 'tracks_grid'

I18n.load_path = Dir[File.dirname(__FILE__) + '/locales/*.yml']
I18n.default_locale = :en

require 'support/database'
Dir[File.dirname(__FILE__) + '/support/*.rb'].each{|f| require f}

def check_include(*args)
  params = args.extract_options!
  scope = PersonGrid.new(:params => params).scope
  all = Set.new scope.all
  expected = Set.new [args].flatten
  #puts "SSSSSSSSSSS scope=#{scope.to_sql}"
  #puts "            all=#{all.inspect}"
  #puts "            expected=#{expected.inspect}"
  specify { all.should == expected }
end

class Array
  def detect_name( name)
    detect{|d| d.name == name }
  end
end

