require 'tracks_grid/base'
require 'tracks_grid/columns'
require 'tracks_grid/breadcrumbs'
require 'tracks_grid/presenter'
require 'tracks_grid/filters'

module TracksGrid

  class Grid
    include Base
    include Columns
    include Breadcrumbs
    include RangeFilter
  end

end
