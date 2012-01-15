module TracksGrid
  
  autoload :Version,   'tracks_grid/version'
  autoload :Grid,      'tracks_grid/grid'
  autoload :decorator, 'tracks_grid/decorator'

  class ConfigurationError < StandardError
  end

end
