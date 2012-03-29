module Gitter
  
  autoload :Version,     'gitter/version'
  autoload :Grid,        'gitter/grid'
  autoload :Helper,      'gitter/helper'
  autoload :Controller,  'gitter/controller'

  class ConfigurationError < StandardError
  end

end
