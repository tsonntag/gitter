module TracksGrid
  
  autoload :Version,   'tracks_grid/version'
  autoload :Grid,      'tracks_grid/grid'
  autoload :Decorator, 'tracks_grid/decorator'
  autoload :Helper,    'tracks_grid/helper'

  class ConfigurationError < StandardError
  end

end
