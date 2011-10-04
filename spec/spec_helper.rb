require 'rubygems'
require 'bundler'
Bundler.setup :default, :development

$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../lib', __FILE__)

require 'rspec'
require 'tracks_grid'

require 'database'
require 'person_grid'
