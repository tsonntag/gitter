module Gitter
  
  autoload :Version,   'gitter/version'
  autoload :Grid,      'gitter/grid'
  autoload :Helper,    'gitter/helper'

  class ConfigurationError < StandardError
  end

end
