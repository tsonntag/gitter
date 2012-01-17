require 'tracks_grid/driver'
require 'tracks_grid/base'
require 'tracks_grid/columns'
require 'tracks_grid/breadcrumbs'
require 'tracks_grid/decorator'
require 'tracks_grid/filters/ranges'

module TracksGrid

  class Grid
    include Base
    include Driver
    include Columns
    include Breadcrumbs
    extend Ranges
  end

end
