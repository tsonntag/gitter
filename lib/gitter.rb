module Gitter
  
  autoload :Version,     'gitter/version'
  autoload :Grid,        'gitter/grid'
  autoload :PivotGrid,   'gitter/pivot_grid'
  autoload :Helper,      'gitter/helper'
  autoload :Controller,  'gitter/controller'
  autoload :Table,       'gitter/table'
  autoload :EnumerableDriver, 'gitter/drivers/enumerable_driver'

  class ConfigurationError < StandardError
  end

end
