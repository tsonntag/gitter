require 'active_support/concern'

require 'tracks_grid/version'
require 'tracks_grid/core'
require 'tracks_grid/columns'

module TracksGrid
  extend ActiveSupport::Concern

  included do
    include Core
    include Columns
  end
  
  class ConfigurationError < StandardError; end

end
