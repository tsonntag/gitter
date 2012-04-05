module Gitter
  
  autoload :Version,     'gitter/version'
  autoload :Grid,        'gitter/grid'
  autoload :PivotGrid,   'gitter/pivot_grid'
  autoload :Helper,      'gitter/helper'
  autoload :Controller,  'gitter/controller'
  autoload :Table,       'gitter/table'

  class ConfigurationError < StandardError
  end

end
